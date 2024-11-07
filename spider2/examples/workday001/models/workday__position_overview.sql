with position_data as (

    select *
    from {{ ref('stg_workday__position') }}
),

position_job_profile_data as (

    select *
    from {{ ref('stg_workday__position_job_profile') }}
),

position_data_enhanced as (

    select
        position_data.position_id,
        position_data.source_relation,
        position_data.position_code,
        position_data.job_posting_title,
        position_data.effective_date, 
        position_data.is_closed,
        position_data.is_hiring_freeze,
        position_data.is_available_for_hire,
        position_data.availability_date,
        position_data.is_available_for_recruiting,
        position_data.earliest_hire_date,
        position_data.is_available_for_overlap,
        position_data.earliest_overlap_date,
        position_data.worker_for_filled_position_id,
        position_data.worker_type_code, 
        position_data.position_time_type_code,
        position_data.supervisory_organization_id, 
        position_job_profile_data.job_profile_id,
        position_data.compensation_package_code,
        position_data.compensation_grade_code,
        position_data.compensation_grade_profile_code
    from position_data
    left join position_job_profile_data 
        on position_job_profile_data.position_id = position_data.position_id
        and position_job_profile_data.source_relation = position_data.source_relation
)

select *
from position_data_enhanced 