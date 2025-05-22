with opportunity as (

    select *
    from {{ ref('lever__opportunity_enhanced') }}
),

stage as (

    select *
    from {{ var('stage') }}
),

lever_user as (

    select *
    from {{ var('user') }}
),

opp_stage_history as (

    select 
        opportunity_id,
        updated_at as valid_from,
        stage_id,
        updater_user_id,
        to_stage_index as stage_index_in_pipeline,
        lead(updated_at) over (partition by opportunity_id order by updated_at asc) as valid_ending_at

    from {{ var('opportunity_stage_history') }}
),

-- joining first to get opportunity.archived_at for the valid_ending_at column
join_opportunity_stage_history as (

    select 
        opp_stage_history.opportunity_id,
        opportunity.contact_name as opportunity_contact_name,
        opp_stage_history.valid_from,
        coalesce(opp_stage_history.valid_ending_at, opportunity.archived_at, {{ dbt.current_timestamp_backcompat() }}) as valid_ending_at,
        stage.stage_name as stage,

        opp_stage_history.stage_id,
        opp_stage_history.stage_index_in_pipeline,

        lever_user.full_name as updater_user_name,
        opportunity.archive_reason, -- if archived later
        opportunity.job_title,
        opportunity.job_department,
        opportunity.job_location,
        opportunity.job_team,
        opportunity.application_type,
        opportunity.sources as application_sources,
        opportunity.hiring_manager_name,
        opportunity.opportunity_owner_name

    from opp_stage_history
    join stage on opp_stage_history.stage_id = stage.stage_id
    left join lever_user on cast(lever_user.user_id as string) = cast(opp_stage_history.updater_user_id as string)  -- 显式类型转换
    join opportunity on cast(opportunity.opportunity_id as string) = cast(opp_stage_history.opportunity_id as string)  -- 显式类型转换
),

final_time_in_stages as (

    select
       *,
        {{ dbt.datediff('valid_from', 'valid_ending_at', 'day') }} as days_in_stage
        
    from join_opportunity_stage_history

)

select * from final_time_in_stages
