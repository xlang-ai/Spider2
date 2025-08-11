{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled','hubspot_engagement_call_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','engagement_call')) }}
from {{ var('engagement_call') }}
