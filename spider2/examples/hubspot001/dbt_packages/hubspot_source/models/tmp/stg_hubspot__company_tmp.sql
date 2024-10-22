{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','company')) }}
from {{ var('company') }}
