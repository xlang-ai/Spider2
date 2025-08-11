{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled','hubspot_engagement_task_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','engagement_task')) }}
from {{ var('engagement_task') }}
