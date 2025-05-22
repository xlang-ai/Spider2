{{ config(enabled=var('marketo__enable_campaigns', False)) }}

with email_sends as (

    select *
    from {{ ref('marketo__email_sends') }}

), aggregated as (

    select
        campaign_id,
        count(*) as count_sends,
        sum(count_opens) as count_opens,
        sum(count_bounces) as count_bounces,
        sum(count_clicks) as count_clicks,
        sum(count_deliveries) as count_deliveries,
        sum(count_unsubscribes) as count_unsubscribes,
        count(distinct case when was_opened = True then email_send_id end) as count_unique_opens,
        count(distinct case when was_clicked = True then email_send_id end) as count_unique_clicks
    from email_sends
    where campaign_id is not null
    group by 1

)

select *
from aggregated