{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled','hubspot_engagement_note_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','engagement_note')) }}
from {{ var('engagement_note') }}
