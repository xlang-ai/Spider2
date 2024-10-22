with page_event as (

    select *
    from {{ var('page_event') }}
),

page as (

    select *
    from {{ ref('int_pendo__page_info') }}
),

account as (

    select *
    from {{ ref('int_pendo__latest_account') }}
), 

visitor as (

    select *
    from {{ ref('int_pendo__latest_visitor') }}
),

add_previous_page as (

    select 
        *,
        -- using _fivetran_synced in case events are sent within the same hour-block
        lag(page_id) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_page_id,
        lag(occurred_at) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_page_event_at,
        lag(num_minutes) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_page_num_minutes,
        lag(num_events) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_page_num_events
    
    from page_event
), 

page_event_join as (

    select
        add_previous_page.*,

        current_page.page_name,
        current_page.rules as page_rules,
        current_page.product_area_name,
        current_page.group_id as product_area_id,
        current_page.app_display_name,
        current_page.app_platform,

        previous_page.page_name as previous_page_name,
        previous_page.product_area_name as previous_product_area_name,
        previous_page.group_id as previous_page_product_area_id

        {{ fivetran_utils.persist_pass_through_columns('pendo__account_history_pass_through_columns') }}
        {{ fivetran_utils.persist_pass_through_columns('pendo__visitor_history_pass_through_columns') }}

    from add_previous_page
    join page as current_page
        on add_previous_page.page_id = current_page.page_id 
    left join page as previous_page
        on add_previous_page.previous_page_id = previous_page.page_id
    left join visitor 
        on visitor.visitor_id = add_previous_page.visitor_id
    left join account
        on account.account_id = add_previous_page.account_id
)

select *
from page_event_join