{{ config(enabled=var('hubspot_property_enabled', True)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__property_option_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__property_option_tmp')),
                staging_columns=get_property_option_columns()
            )
        }}
    from base

), fields as (

    select
        label as property_option_label,	
        property_id,
        _fivetran_synced,
        display_order,
        hidden,
        value as property_option_value
    from macro
    
)

select *
from fields
