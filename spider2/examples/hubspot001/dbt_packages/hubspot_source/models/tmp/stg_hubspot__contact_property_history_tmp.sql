{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_property_enabled', 'hubspot_contact_property_history_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','contact_property_history')) }}
from {{ var('contact_property_history') }}
