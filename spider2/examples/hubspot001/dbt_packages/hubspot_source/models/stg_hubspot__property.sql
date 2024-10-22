{{ config(enabled=var('hubspot_property_enabled', True)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__property_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__property_tmp')),
                staging_columns=get_property_columns()
            )
        }}
    from base

), fields as (

    select
        _fivetran_id,
        _fivetran_synced,
        calculated,
        created_at,
        description,
        field_type,
        group_name,
        hubspot_defined,
        hubspot_object,
        label as property_label,
        name as property_name,
        type as property_type,
        updated_at
    from macro
    
)

select *
from fields
