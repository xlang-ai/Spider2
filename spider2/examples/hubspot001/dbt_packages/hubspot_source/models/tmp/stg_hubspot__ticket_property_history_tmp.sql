{{ config(enabled=var('hubspot_service_enabled', False)) }}

select {{ dbt_utils.star(source('hubspot','ticket_property_history')) }}
from {{ var('ticket_property_history') }}
