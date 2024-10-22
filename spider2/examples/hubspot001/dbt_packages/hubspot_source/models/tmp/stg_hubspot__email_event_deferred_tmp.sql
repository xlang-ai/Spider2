{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_deferred_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','email_event_deferred')) }}
from {{ var('email_event_deferred') }}
