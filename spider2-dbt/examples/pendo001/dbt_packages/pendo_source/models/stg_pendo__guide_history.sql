
with base as (

    select * 
    from {{ ref('stg_pendo__guide_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__guide_history_tmp')),
                staging_columns=get_guide_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as guide_id,
        name as guide_name,
        app_id,
        state,
        attribute_device_type as device_type,
        created_at,
        created_by_user_id,
        is_multi_step,
        is_training,
        last_updated_at,
        last_updated_by_user_id,
        launch_method,
        published_at,
        recurrence,
        recurrence_eligibility_window,
        reset_at,
        root_version_id,
        stable_version_id,
        
        _fivetran_synced

    from fields
)

select * 
from final
