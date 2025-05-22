with interview as (

    select *
    from {{ ref('int_greenhouse__interview_users') }}
),

job_stage as (

    select *
    from {{ ref('stg_greenhouse__job_stage') }}
),

-- this has job info!
application as (

    select *
    from {{ ref('int_greenhouse__application_info') }}
),

final as (

    select
        interview.*,
        application.full_name as candidate_name,
        job_stage.stage_name as job_stage,
        application.current_job_stage as application_current_job_stage,
        application.status as current_application_status,
        application.job_title,
        application.job_id,

        application.hiring_managers like ('%' || interview.interviewer_name || '%')  as interviewer_is_hiring_manager,
        application.hiring_managers,
        application.recruiter_name
        ,
        application.job_offices

        ,
        application.job_departments,
        application.job_parent_departments

        ,
        application.candidate_gender,
        application.candidate_disability_status,
        application.candidate_race,
        application.candidate_veteran_status

    from interview
    left join job_stage 
        on interview.job_stage_id = job_stage.job_stage_id
    left join 
        application on interview.application_id = application.application_id
)

select * from final