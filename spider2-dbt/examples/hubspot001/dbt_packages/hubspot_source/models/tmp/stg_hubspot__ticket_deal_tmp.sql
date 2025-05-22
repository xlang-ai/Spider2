{{ config(enabled=(var('hubspot_service_enabled', false) and var('hubspot_ticket_deal_enabled', false))) }}

select {{ dbt_utils.star(source('hubspot','ticket_deal')) }}
from {{ var('ticket_deal') }}
