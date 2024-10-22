
with base as (

    select * 
    from {{ ref('stg_pendo__guide_step_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__guide_step_history_tmp')),
                staging_columns=get_guide_step_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
    
        guide_id,
        guide_last_updated_at,
        step_id,
        _fivetran_synced

    from fields
)

select * 
from final
