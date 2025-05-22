
with base as (

    select * 
    from {{ ref('stg_pendo__application_history_tmp') }}

    where not coalesce(is_deleted, false)

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__application_history_tmp')),
                staging_columns=get_application_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as application_id,
        agent_policy_prod,
        agent_policy_staging,
        agent_version_prod,
        agent_version_staging,
        created_at,
        created_by_user_id,
        description,
        display_name,
        event_count,
        first_event_time as first_event_at,
        integrated as is_integrated,
        is_deleted,
        last_updated_at,
        last_updated_by_user_id,
        name as application_name,
        platform,
        subscription_id,
        _fivetran_synced

    from fields
)

select * 
from final
