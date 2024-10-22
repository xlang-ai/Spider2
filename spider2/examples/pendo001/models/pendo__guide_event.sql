with guide_event as (

    select *
    from {{ var('guide_event') }}
),

guide as (

    select *
    from {{ ref('int_pendo__guide_info') }}
),

account as (

    select *
    from {{ ref('int_pendo__latest_account') }}
), 

visitor as (

    select *
    from {{ ref('int_pendo__latest_visitor') }}
),

guide_event_join as (

    select
        guide_event.*,
        guide.guide_name,
        guide.app_display_name,
        guide.app_platform

        {{ fivetran_utils.persist_pass_through_columns('pendo__account_history_pass_through_columns') }}
        {{ fivetran_utils.persist_pass_through_columns('pendo__visitor_history_pass_through_columns') }}

    from guide_event
    join guide
        on guide.guide_id = guide_event.guide_id
    left join visitor 
        on visitor.visitor_id = guide_event.visitor_id
    left join account
        on account.account_id = guide_event.account_id
)

select *
from guide_event_join