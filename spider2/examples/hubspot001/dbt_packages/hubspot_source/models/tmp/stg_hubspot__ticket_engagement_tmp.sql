{{ config(enabled=var('hubspot_service_enabled', False)) }}

select {{ dbt_utils.star(source('hubspot','ticket_engagement')) }}
from {{ var('ticket_engagement') }}
