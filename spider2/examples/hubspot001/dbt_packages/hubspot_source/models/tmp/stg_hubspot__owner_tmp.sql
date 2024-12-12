{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_owner_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','owner')) }}
from {{ var('owner') }}
