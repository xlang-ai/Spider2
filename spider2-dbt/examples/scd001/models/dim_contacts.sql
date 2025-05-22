{% set personal_emails = get_personal_emails() %}

with users as (

    select * from {{ ref('stg_users') }} 

),

events as (

    select * from {{ ref('stg_events') }}

),

user_events as (

    select
        user_id,
        min(timestamp) as first_event,
        max(timestamp) as most_recent_event,
        count(event_id) as number_of_events
    from events
    group by 1

),

order_events as (

    select
        user_id,
        min(timestamp) as first_order,
        max(timestamp) as most_recent_order,
        count(event_id) as number_of_orders
    from events
    where event_name = 'order_placed'
    group by 1

),

final_all_users as (

    select
        users.user_id,
        users.user_name,
        users.gaggle_id,
        users.email,
        users.created_at,
        user_events.first_event,
        user_events.most_recent_event,
        user_events.number_of_events,
        order_events.first_order,
        order_events.most_recent_order,
        order_events.number_of_orders,
        case 
            when users.email_domain in {{ personal_emails }} then null
            else users.email_domain 
        end as corporate_email
    from users
    left join user_events
        on users.user_id = user_events.user_id
    left join order_events
        on users.user_id = order_events.user_id

),

final_merged_users as (
    select
        coalesce(fmu.user_id, fau.user_id) as user_id,
        coalesce(fmu.email, fau.email) as email,
        coalesce(fmu.corporate_email, fau.corporate_email) as corporate_email,
        split_part(group_concat(fau.user_name order by fau.created_at desc), ',', 1) as user_name,
        max(fau.gaggle_id) as gaggle_id,
        min(fau.created_at) as created_at,
        min(fau.first_event) as first_event,
        min(fau.most_recent_event) as most_recent_event,
        sum(fau.number_of_events) as number_of_events,
        min(fau.first_order) as first_order,
        min(fau.most_recent_order) as most_recent_order,
        sum(fau.number_of_orders) as number_of_orders
    from final_all_users fau
    left join {{ source('main', 'merged_user') }} mu on fau.email = mu.old_email
    left join final_all_users fmu on fmu.email = mu.new_email 
    group by 1, 2, 3
)

select * from final_merged_users
