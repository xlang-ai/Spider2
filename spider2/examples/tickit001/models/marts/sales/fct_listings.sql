{{ config(materialized='table', sort='list_id', dist='list_id') }}

with listings as (

    select * from {{ ref('stg_tickit__listings') }}

),

categories as (

    select * from {{ ref('stg_tickit__categories') }}

),

events as (

    select * from {{ ref('stg_tickit__events') }}

),

venues as (

    select * from {{ ref('stg_tickit__venues') }}

),

event_detail as (

    select distinct 
        e.event_id,
        e.event_name,
        e.start_time,
        v.venue_name,
        v.venue_city,
        v.venue_state,
        c.cat_group,
        c.cat_name
    from 
        events as e
            join categories as c on c.cat_id = e.cat_id
            join venues as v on v.venue_id = e.venue_id

),

sellers as (

    select * from {{ ref('int_sellers_extracted_from_users') }}

),

dates as (

    select * from {{ ref('stg_tickit__dates') }}

),

final as (

    select
        l.list_id,
        l.list_time,
        e.cat_group,
        e.cat_name,
        e.event_name,
        e.venue_name,
        e.venue_city,
        e.venue_state,
        e.start_time,
        s.username as seller_username,
        s.full_name as seller_name,
        l.num_tickets,
        l.price_per_ticket,
        l.total_price
    from 
        listings as l
            join event_detail as e on e.event_id = l.event_id
            join dates as d on d.date_id = l.date_id
            join sellers as s on s.user_id = l.seller_id
    order by 
        l.list_id

)

select * from final