{{ config(enabled=var('lever_using_requisitions', True)) }}

with base as (

    select * 
    from {{ ref('stg_lever__requisition_posting_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__requisition_posting_tmp')),
                staging_columns=get_requisition_posting_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        posting_id,
        requisition_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
