{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled'])) }}

with events as (

    select *
    from {{ var('email_event') }}

), aggregates as (

    select
        sent_by_event_id as email_send_id,
        count(case when event_type = 'OPEN' then sent_by_event_id end) as opens,
        count(case when event_type = 'SENT' then sent_by_event_id end) as sends,
        count(case when event_type = 'DELIVERED' then sent_by_event_id end) as deliveries,
        count(case when event_type = 'DROPPED' then sent_by_event_id end) as drops,
        count(case when event_type = 'CLICK' then sent_by_event_id end) as clicks,
        count(case when event_type = 'FORWARD' then sent_by_event_id end) as forwards,
        count(case when event_type = 'DEFERRED' then sent_by_event_id end) as deferrals,
        count(case when event_type = 'BOUNCE' then sent_by_event_id end) as bounces,
        count(case when event_type = 'SPAMREPORT' then sent_by_event_id end) as spam_reports,
        count(case when event_type = 'PRINT' then sent_by_event_id end) as prints
    from events
    where sent_by_event_id is not null
    group by 1

)

select *
from aggregates