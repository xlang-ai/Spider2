
with base as (

    select * 
    from {{ ref('stg_asana__task_follower_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__task_follower_tmp')),
                staging_columns=get_task_follower_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        task_id,
        user_id
    from fields
)

select * 
from final
