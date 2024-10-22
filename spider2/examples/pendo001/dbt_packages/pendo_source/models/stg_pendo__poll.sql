
with base as (

    select * 
    from {{ ref('stg_pendo__poll_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__poll_tmp')),
                staging_columns=get_poll_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as poll_id,
        attribute_display,
        attribute_follow_up as follow_up_poll_id,
        attribute_max_length,
        attribute_type,
        question,
        reset_at,
        _fivetran_synced

    from fields
)

select * 
from final
