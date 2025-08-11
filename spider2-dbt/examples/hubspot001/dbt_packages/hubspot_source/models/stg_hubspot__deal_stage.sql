{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with base as (

    select * 
    from {{ ref('stg_hubspot__deal_stage_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__deal_stage_tmp')),
                staging_columns=get_deal_stage_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(date_entered as {{ dbt.type_timestamp() }}) as date_entered,
        deal_id,
        source,
        source_id,
        value as deal_stage_name,
        _fivetran_active,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start
    from fields
)

select * 
from final
