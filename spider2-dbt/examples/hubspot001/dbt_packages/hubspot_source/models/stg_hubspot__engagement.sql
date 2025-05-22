{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__engagement_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__engagement_tmp')),
                staging_columns=get_engagement_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        id as engagement_id,
        created_timestamp,
        owner_id,
        occurred_timestamp,
        portal_id,
        engagement_type,
        is_active
    from macro
    
)

select *
from fields


