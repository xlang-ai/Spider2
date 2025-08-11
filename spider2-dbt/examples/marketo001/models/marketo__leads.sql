with leads as (

    select *
    from {{ ref('int_marketo__lead') }}

), email_stats as (

    select *
    from {{ ref('marketo__email_stats__by_lead') }}

), joined as (

    select
        leads.*,
        coalesce(email_stats.count_sends, 0) as count_sends,
        coalesce(email_stats.count_opens, 0) as count_opens,
        coalesce(email_stats.count_bounces, 0) as count_bounces,
        coalesce(email_stats.count_clicks, 0) as count_clicks,
        coalesce(email_stats.count_deliveries, 0) as count_deliveries,
        coalesce(email_stats.count_unsubscribes, 0) as count_unsubscribes,
        coalesce(email_stats.count_unique_opens, 0) as count_unique_opens,
        coalesce(email_stats.count_unique_clicks, 0) as count_unique_clicks
    from leads
    left join email_stats
        using (lead_id)
)

select *
from joined