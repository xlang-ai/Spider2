{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_deal_property_history_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','deal_property_history')) }}
from {{ var('deal_property_history') }}
