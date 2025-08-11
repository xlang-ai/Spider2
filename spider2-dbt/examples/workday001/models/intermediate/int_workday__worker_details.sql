with worker_data as (

    select 
        *,
        {{ dbt.current_timestamp() }} as current_date
    from {{ ref('stg_workday__worker') }}
),

worker_details as (

    select 
        worker_id,
        source_relation,
        worker_code,
        user_id,
        universal_id,
        case when is_active then true else false end as is_user_active,
        case when hire_date <= current_date
            and (termination_date is null or termination_date > current_date)
            then true 
            else false 
        end as is_employed,
        hire_date,
        case when termination_date > current_date then null
            else termination_date 
        end as departure_date,    
        case when termination_date is null
            then {{ dbt.datediff('hire_date', 'current_date', 'day') }}
            else {{ dbt.datediff('hire_date', 'termination_date', 'day') }}
        end as days_as_worker,
        is_terminated,
        primary_termination_category,
        primary_termination_reason,
        case
            when is_terminated and is_regrettable_termination then true
            when is_terminated and not is_regrettable_termination then false
            else null
        end as is_regrettable_termination, 
        compensation_effective_date,
        employee_compensation_frequency,
        annual_currency_summary_currency,
        annual_currency_summary_total_base_pay,
        annual_currency_summary_primary_compensation_basis,
        annual_summary_currency,
        annual_summary_total_base_pay,
        annual_summary_primary_compensation_basis,
        compensation_grade_id,
        compensation_grade_profile_id
    from worker_data
)

select * 
from worker_details