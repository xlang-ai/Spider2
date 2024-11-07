
with base as (

    select * 
    from {{ ref('stg_lever__interview_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__interview_tmp')),
                staging_columns=get_interview_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(canceled_at as {{ dbt.type_timestamp() }}) as canceled_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        creator_id as creator_user_id,
        cast(date as {{ dbt.type_timestamp() }}) as occurred_at,
        duration as duration_minutes,
        feedback_reminder as feedback_reminder_frequency,
        gcal_event_url,
        id as interview_id,
        location,
        note,
        opportunity_id,
        panel_id,
        stage_id as opportunity_stage_id,
        subject,
        timezone
    from fields
)

select * 
from final
