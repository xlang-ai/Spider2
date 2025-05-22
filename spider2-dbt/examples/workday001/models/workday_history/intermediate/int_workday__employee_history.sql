{{ config(enabled=var('employee_history_enabled', False)) }}

with worker_history as (

    select *
    from {{ ref('stg_workday__worker_history') }}
),

worker_position_history as (

    select *
    from {{ ref('stg_workday__worker_position_history') }}
),

personal_information_history as (

    select *
    from {{ ref('stg_workday__personal_information_history') }}
),

worker_start_records as (

    select worker_id,
        source_relation, 
        _fivetran_start
    from worker_history
    union distinct
    select worker_id,
        source_relation, 
        _fivetran_start 
    from worker_position_history
    union distinct
    select worker_id,
        source_relation, 
        _fivetran_start
    from personal_information_history
    order by worker_id, source_relation, _fivetran_start 
),

worker_history_end_values as (

    select *,
        lead({{ dbt.dateadd('microsecond', -1, '_fivetran_start') }} ) over(partition by worker_id, source_relation order by _fivetran_start) as eventual_fivetran_end
    from worker_start_records   
),

worker_history_scd as (

    select *,
        coalesce(cast(eventual_fivetran_end as {{ dbt.type_timestamp() }}),
            cast('9999-12-31 23:59:59.999000' as {{ dbt.type_timestamp() }})) as _fivetran_end
    from worker_history_end_values
),

employee_history_scd as (

    select 
        worker_history_scd.worker_id,
        worker_history_scd.source_relation,
        worker_position_history.position_id,
        worker_history_scd._fivetran_start,
        worker_history_scd._fivetran_end,
        worker_history._fivetran_active as is_wh_fivetran_active,
        worker_position_history._fivetran_active as is_wph_fivetran_active,
        personal_information_history._fivetran_active as is_pih_fivetran_active, 
        worker_history.academic_tenure_date,
        worker_history.is_active,
        worker_history.active_status_date,
        worker_history.annual_currency_summary_currency,
        worker_history.annual_currency_summary_frequency,
        worker_history.annual_currency_summary_primary_compensation_basis,
        worker_history.annual_currency_summary_total_base_pay,
        worker_history.annual_currency_summary_total_salary_and_allowances,
        worker_history.annual_summary_currency,
        worker_history.annual_summary_frequency,
        worker_history.annual_summary_primary_compensation_basis,
        worker_history.annual_summary_total_base_pay,
        worker_history.annual_summary_total_salary_and_allowances,
        worker_history.benefits_service_date,
        worker_history.company_service_date,
        worker_history.compensation_effective_date,
        worker_history.compensation_grade_id,
        worker_history.compensation_grade_profile_id,
        worker_history.continuous_service_date,
        worker_history.contract_assignment_details,
        worker_history.contract_currency_code,
        worker_history.contract_end_date,
        worker_history.contract_frequency_name,
        worker_history.contract_pay_rate,
        worker_history.contract_vendor_name,
        worker_history.date_entered_workforce,
        worker_history.days_unemployed,
        worker_history.eligible_for_hire,
        worker_history.eligible_for_rehire_on_latest_termination,
        worker_history.employee_compensation_currency,
        worker_history.employee_compensation_frequency,
        worker_history.employee_compensation_primary_compensation_basis,
        worker_history.employee_compensation_total_base_pay,
        worker_history.employee_compensation_total_salary_and_allowances,
        worker_history.end_employment_date, 
        worker_history.expected_date_of_return,
        worker_history.expected_retirement_date,
        worker_history.first_day_of_work,
        worker_history.is_has_international_assignment,
        worker_history.hire_date,
        worker_history.hire_reason,
        worker_history.is_hire_rescinded,
        worker_history.home_country,
        worker_history.hourly_frequency_currency,
        worker_history.hourly_frequency_frequency,
        worker_history.hourly_frequency_primary_compensation_basis,
        worker_history.hourly_frequency_total_base_pay,
        worker_history.hourly_frequency_total_salary_and_allowances,
        worker_history.last_datefor_which_paid,
        worker_history.local_termination_reason,
        worker_history.months_continuous_prior_employment,
        worker_history.is_not_returning,
        worker_history.original_hire_date,
        worker_history.pay_group_frequency_currency,
        worker_history.pay_group_frequency_frequency,
        worker_history.pay_group_frequency_primary_compensation_basis,
        worker_history.pay_group_frequency_total_base_pay,
        worker_history.pay_group_frequency_total_salary_and_allowances,
        worker_history.pay_through_date,
        worker_history.primary_termination_category,
        worker_history.primary_termination_reason,
        worker_history.probation_end_date,
        worker_history.probation_start_date,
        worker_history.reason_reference_id,
        worker_history.is_regrettable_termination,
        worker_history.is_rehire,
        worker_history.resignation_date,
        worker_history.is_retired,
        worker_history.retirement_date,
        worker_history.retirement_eligibility_date,
        worker_history.is_return_unknown,
        worker_history.seniority_date,
        worker_history.severance_date,
        worker_history.is_terminated,
        worker_history.termination_date,
        worker_history.is_termination_involuntary,
        worker_history.termination_last_day_of_work,
        worker_history.time_off_service_date,
        worker_history.universal_id,
        worker_history.user_id,
        worker_history.vesting_date,
        worker_history.worker_code,
        worker_position_history.position_location,
        worker_position_history.is_exclude_from_head_count,
        worker_position_history.fte_percent,
        worker_position_history.is_job_exempt,
        worker_position_history.is_specify_paid_fte,
        worker_position_history.is_specify_working_fte,
        worker_position_history.is_work_shift_required,
        worker_position_history.academic_pay_setup_data_annual_work_period_end_date,
        worker_position_history.academic_pay_setup_data_annual_work_period_start_date,
        worker_position_history.academic_pay_setup_data_annual_work_period_work_percent_of_year,
        worker_position_history.academic_pay_setup_data_disbursement_plan_period_end_date,
        worker_position_history.academic_pay_setup_data_disbursement_plan_period_start_date,
        worker_position_history.business_site_summary_display_language,
        worker_position_history.business_site_summary_local,
        worker_position_history.business_site_summary_location_type,
        worker_position_history.business_site_summary_name,
        worker_position_history.business_site_summary_scheduled_weekly_hours,
        worker_position_history.business_site_summary_time_profile,
        worker_position_history.business_title,
        worker_position_history.is_critical_job,
        worker_position_history.default_weekly_hours,
        worker_position_history.difficulty_to_fill,
        worker_position_history.position_effective_date,
        worker_position_history.employee_type,
        worker_position_history.position_end_date,
        worker_position_history.expected_assignment_end_date,
        worker_position_history.external_employee,
        worker_position_history.federal_withholding_fein,
        worker_position_history.frequency,
        worker_position_history.headcount_restriction_code,
        worker_position_history.host_country,
        worker_position_history.international_assignment_type,
        worker_position_history.is_primary_job,
        worker_position_history.job_profile_id,
        worker_position_history.management_level_code,
        worker_position_history.paid_fte,
        worker_position_history.pay_group,
        worker_position_history.pay_rate,
        worker_position_history.pay_rate_type,
        worker_position_history.payroll_entity,
        worker_position_history.payroll_file_number,
        worker_position_history.regular_paid_equivalent_hours,
        worker_position_history.scheduled_weekly_hours,
        worker_position_history.position_start_date,
        worker_position_history.start_international_assignment_reason,
        worker_position_history.work_hours_profile,
        worker_position_history.work_shift,
        worker_position_history.work_space,
        worker_position_history.worker_hours_profile_classification,
        worker_position_history.working_fte,
        worker_position_history.working_time_frequency,
        worker_position_history.working_time_unit,
        worker_position_history.working_time_value,
        personal_information_history.additional_nationality,
        personal_information_history.blood_type,
        personal_information_history.citizenship_status,
        personal_information_history.city_of_birth,
        personal_information_history.city_of_birth_code,
        personal_information_history.country_of_birth,
        personal_information_history.date_of_birth,
        personal_information_history.date_of_death,
        personal_information_history.gender, 
        personal_information_history.is_hispanic_or_latino,
        personal_information_history.hukou_locality,
        personal_information_history.hukou_postal_code,
        personal_information_history.hukou_region,
        personal_information_history.hukou_subregion,
        personal_information_history.hukou_type,
        personal_information_history.last_medical_exam_date,
        personal_information_history.last_medical_exam_valid_to,
        personal_information_history.is_local_hukou, 
        personal_information_history.marital_status,
        personal_information_history.marital_status_date,
        personal_information_history.medical_exam_notes,
        personal_information_history.native_region,
        personal_information_history.native_region_code,
        personal_information_history.personnel_file_agency,
        personal_information_history.political_affiliation,
        personal_information_history.primary_nationality,
        personal_information_history.region_of_birth,
        personal_information_history.region_of_birth_code,
        personal_information_history.religion,
        personal_information_history.social_benefit,
        personal_information_history.is_tobacco_use,
        personal_information_history.type

    from worker_history_scd

    left join worker_history 
        on worker_history_scd.worker_id = worker_history.worker_id
        and worker_history_scd.source_relation = worker_history.source_relation
        and worker_history_scd._fivetran_start <= worker_history._fivetran_end
        and worker_history_scd._fivetran_end >= worker_history._fivetran_start

    left join worker_position_history 
        on worker_history_scd.worker_id = worker_position_history.worker_id
        and worker_history_scd.source_relation = worker_position_history.source_relation
        and worker_history_scd._fivetran_start <= worker_position_history._fivetran_end
        and worker_history_scd._fivetran_end >= worker_position_history._fivetran_start

    left join personal_information_history
        on worker_history_scd.worker_id = personal_information_history.worker_id
        and worker_history_scd.source_relation = personal_information_history.source_relation
        and worker_history_scd._fivetran_start <= personal_information_history._fivetran_end
        and worker_history_scd._fivetran_end >= personal_information_history._fivetran_start

),

employee_key as (

    select {{ dbt_utils.generate_surrogate_key(['worker_id', 'source_relation', 'position_id', 'position_start_date']) }} as employee_id,
        cast(_fivetran_start as date) as _fivetran_date,
        employee_history_scd.*
    from employee_history_scd
),

history_surrogate_key as (

    select {{ dbt_utils.generate_surrogate_key(['employee_id', '_fivetran_date']) }} as history_unique_key,
        employee_key.*
    from employee_key
)

select * 
from history_surrogate_key


