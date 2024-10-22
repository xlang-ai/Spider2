{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled','hubspot_company_property_history_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','company_property_history')) }}
from {{ var('company_property_history') }}
