
with base as (

    select * 
    from {{ ref('stg_asana__story_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__story_tmp')),
                staging_columns=get_story_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as story_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        created_by_id as created_by_user_id,
        target_id as target_task_id,
        text as story_content,
        type as event_type
    from fields
)

select * 
from final
