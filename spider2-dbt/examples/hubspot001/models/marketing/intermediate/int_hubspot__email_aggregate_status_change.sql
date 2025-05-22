
{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_status_change_enabled'])) }}

with base as (

    select *
    from {{ ref('hubspot__email_event_status_change') }}

), aggregates as (

    select
        email_campaign_id,
        email_send_id,
        count(case when subscription_status = 'UNSUBSCRIBED' then 1 end) as unsubscribes
    from base
    where email_send_id is not null
    group by 1,2

)

select *
from aggregates
