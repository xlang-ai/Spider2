{{ config(enabled=var('hubspot_service_enabled', False)) }}

select {{ dbt_utils.star(source('hubspot','ticket_pipeline')) }}
from {{ var('ticket_pipeline') }}
