{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled']) and var('hubspot_merged_deal_enabled', False)) }}

with base as (

    select * 
    from {{ ref('stg_hubspot__merged_deal_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__merged_deal_tmp')),
                staging_columns=get_merged_deal_columns()
            )
        }}
    from base

), fields as (
    
    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        deal_id,
        merged_deal_id
    from macro
)

select *
from fields
