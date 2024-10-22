-- making this its own model so i can use dbt_utils.star for the pivoted out columns
with guide_event as (

    select *
    from {{ ref('pendo__guide_event') }}
),

calculate_metrics as (

    select
        guide_id,
        count(distinct visitor_id) as count_visitors,
        count(distinct account_id) as count_accounts,
        count(*) as count_events,
        min(occurred_at) as first_event_at,
        max(occurred_at) as last_event_at

    from guide_event
    group by 1

)

select *
from calculate_metrics