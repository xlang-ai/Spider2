{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_owner_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__owner_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__owner_tmp')),
                staging_columns=get_owner_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_timestamp,
        email as email_address,
        first_name,
        last_name,
        owner_id,
        portal_id,
        type as owner_type,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_timestamp,
        trim( {{ dbt.concat(['first_name', "' '", 'last_name']) }} ) as full_name
    from macro
    
)

select *
from fields


