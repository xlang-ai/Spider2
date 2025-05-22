with feature_event as (

    select *
    from {{ var('feature_event') }}
),

feature as (

    select *
    from {{ ref('int_pendo__feature_info') }}
),

account as (

    select *
    from {{ ref('int_pendo__latest_account') }}
), 

visitor as (

    select *
    from {{ ref('int_pendo__latest_visitor') }}
),

add_previous_feature as (

    select 
        *,
        lag(feature_id) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_feature_id,
        lag(occurred_at) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_feature_event_at,
        lag(num_minutes) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_feature_num_minutes,
        lag(num_events) over(partition by visitor_id order by occurred_at asc, _fivetran_synced asc) as previous_feature_num_events

    from feature_event
), 

feature_event_join as (

    select
        add_previous_feature.*,
        
        current_feature.feature_name,
        current_feature.page_id,
        current_feature.page_name,
        current_feature.product_area_name,
        current_feature.group_id as product_area_id,
        current_feature.app_display_name,
        current_feature.app_platform,

        previous_feature.feature_name as previous_feature_name,
        previous_feature.page_id as previous_feature_page_id,
        previous_feature.page_name as previous_feature_page_name,
        previous_feature.product_area_name as previous_feature_product_area_name,
        previous_feature.group_id as previous_feature_product_area_id

        {{ fivetran_utils.persist_pass_through_columns('pendo__account_history_pass_through_columns') }}
        {{ fivetran_utils.persist_pass_through_columns('pendo__visitor_history_pass_through_columns') }}

    from add_previous_feature
    join feature as current_feature
        on add_previous_feature.feature_id = current_feature.feature_id 
    left join feature as previous_feature 
        on add_previous_feature.previous_feature_id = previous_feature.feature_id

    left join visitor 
        on visitor.visitor_id = add_previous_feature.visitor_id
    left join account
        on account.account_id = add_previous_feature.account_id
)


select *
from feature_event_join