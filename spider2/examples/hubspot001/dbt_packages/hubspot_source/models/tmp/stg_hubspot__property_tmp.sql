{{ config(enabled=var('hubspot_property_enabled', True)) }}

select {{ dbt_utils.star(source('hubspot','property')) }}
from {{ var('property') }}
