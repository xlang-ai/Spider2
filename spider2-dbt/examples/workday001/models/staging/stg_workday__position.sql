
with base as (

    select * 
    from {{ ref('stg_workday__position_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__position_base')),
                staging_columns=get_position_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='workday_union_schemas', 
            union_database_variable='workday_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation,
        _fivetran_synced,
        academic_tenure_eligible as is_academic_tenure_eligible,
        availability_date,
        available_for_hire as is_available_for_hire,
        available_for_overlap as is_available_for_overlap,
        available_for_recruiting as is_available_for_recruiting,
        closed as is_closed,
        compensation_grade_code,
        compensation_grade_profile_code,
        compensation_package_code,
        compensation_step_code,
        critical_job as is_critical_job,
        difficulty_to_fill_code,
        earliest_hire_date,
        earliest_overlap_date,
        effective_date,
        hiring_freeze as is_hiring_freeze,
        id as position_id,
        job_description,
        job_description_summary,
        job_posting_title,
        position_code,
        position_time_type_code,
        primary_compensation_basis,
        primary_compensation_basis_amount_change,
        primary_compensation_basis_percent_change,
        supervisory_organization_id,
        work_shift_required as is_work_shift_required,
        worker_for_filled_position_id,
        worker_position_id,
        worker_type_code
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
