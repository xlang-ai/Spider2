
with base as (

    select * 
    from {{ ref('stg_lever__stage_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__stage_tmp')),
                staging_columns=get_stage_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as stage_id,
        text as stage_name,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
