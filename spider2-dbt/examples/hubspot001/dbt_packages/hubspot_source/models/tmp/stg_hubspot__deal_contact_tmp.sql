{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_deal_contact_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','deal_contact')) }}
from {{ var('deal_contact') }}
