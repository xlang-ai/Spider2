{{ config(enabled=var('lever_using_requisitions', True)) }}

with base as (

    select * 
    from {{ ref('stg_lever__requisition_offer_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__requisition_offer_tmp')),
                staging_columns=get_requisition_offer_columns()
            )
        }}
        
    from base
),

final as (
    
    select
        requisition_id,
        offer_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        _fivetran_deleted
    from fields
)

select * 
from final