{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ ref('stg_workday__worker_base') }}
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %} 
),

fill_columns as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__worker_base')),
                staging_columns=get_worker_history_columns()
            )
        }}

        {{ 
            fivetran_utils.source_relation(
                union_schema_variable='workday_union_schemas', 
                union_database_variable='workday_union_databases'
                ) 
        }}

    from base
),

final as (

    select 
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation', '_fivetran_start']) }} as history_unique_key,
        id as worker_id, 
        source_relation,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date,
        _fivetran_active,
        academic_tenure_date,
        active as is_active,
        active_status_date,
        annual_currency_summary_currency,
        annual_currency_summary_frequency,
        annual_currency_summary_primary_compensation_basis,
        annual_currency_summary_total_base_pay,
        annual_currency_summary_total_salary_and_allowances,
        annual_summary_currency,
        annual_summary_frequency,
        annual_summary_primary_compensation_basis,
        annual_summary_total_base_pay,
        annual_summary_total_salary_and_allowances,
        benefits_service_date,
        company_service_date,
        compensation_effective_date,
        compensation_grade_id,
        compensation_grade_profile_id,
        continuous_service_date,
        contract_assignment_details,
        contract_currency_code,
        contract_end_date,
        contract_frequency_name,
        contract_pay_rate,
        contract_vendor_name,
        date_entered_workforce,
        days_unemployed,
        eligible_for_hire,
        eligible_for_rehire_on_latest_termination,
        employee_compensation_currency,
        employee_compensation_frequency,
        employee_compensation_primary_compensation_basis,
        employee_compensation_total_base_pay,
        employee_compensation_total_salary_and_allowances,
        cast(end_employment_date as {{ dbt.type_timestamp() }}) as end_employment_date, 
        expected_date_of_return,
        expected_retirement_date,
        first_day_of_work,
        has_international_assignment as is_has_international_assignment,
        hire_date,
        hire_reason,
        hire_rescinded as is_hire_rescinded,
        home_country,
        hourly_frequency_currency,
        hourly_frequency_frequency,
        hourly_frequency_primary_compensation_basis,
        hourly_frequency_total_base_pay,
        hourly_frequency_total_salary_and_allowances,
        last_datefor_which_paid,
        local_termination_reason,
        months_continuous_prior_employment,
        not_returning as is_not_returning,
        original_hire_date,
        pay_group_frequency_currency,
        pay_group_frequency_frequency,
        pay_group_frequency_primary_compensation_basis,
        pay_group_frequency_total_base_pay,
        pay_group_frequency_total_salary_and_allowances,
        pay_through_date,
        primary_termination_category,
        primary_termination_reason,
        probation_end_date,
        probation_start_date,
        reason_reference_id,
        regrettable_termination as is_regrettable_termination,
        rehire as is_rehire,
        resignation_date,
        retired as is_retired,
        retirement_date,
        retirement_eligibility_date,
        return_unknown as is_return_unknown,
        seniority_date,
        severance_date,
        terminated as is_terminated,
        cast(termination_date as {{ dbt.type_timestamp() }}) as termination_date,
        termination_involuntary as is_termination_involuntary,
        termination_last_day_of_work,
        time_off_service_date,
        universal_id,
        user_id,
        vesting_date,
        worker_code
    from fill_columns
)

select *
from final