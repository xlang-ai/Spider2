{{ config(enabled=var('employee_history_enabled', False)) }}    

with row_month_partition as (

    select *, 
        cast({{ dbt.date_trunc("month", "date_day") }} as date) as date_month,
        row_number() over (partition by employee_id, source_relation, extract(year from date_day), extract(month from date_day) order by date_day desc) AS recent_dom_row
    from {{ ref('workday__employee_daily_history') }}
),

end_of_month_history as (
    
    select *,
        {{ dbt.current_timestamp() }} as current_date
    from row_month_partition
    where recent_dom_row = 1
),

months_employed as (

    select *,
        case when termination_date is null
            then {{ dbt.datediff("hire_date", "current_date", "day") }}
            else {{ dbt.datediff("hire_date", "termination_date", "day") }}
        end as days_as_worker,
        case when position_end_date is null
            then {{ dbt.datediff('position_start_date', 'current_date', 'day') }}
            else {{ dbt.datediff('position_start_date', 'position_end_date', 'day') }}
        end as days_as_employee
    from end_of_month_history
),

monthly_employee_metrics as (

    select 
        date_month,
        source_relation,
        sum(case when date_month = cast({{ dbt.date_trunc("month", "position_effective_date") }} as date) then 1 else 0 end) as new_employees,
        sum(case when date_month = cast({{ dbt.date_trunc("month", "termination_date") }} as date) then 1 else 0 end) as churned_employees,
        sum(case when (date_month = cast({{ dbt.date_trunc("month", "termination_date") }} as date) and lower(primary_termination_category) = 'terminate_employee_voluntary') then 1 else 0 end) as churned_voluntary_employees,
        sum(case when (date_month = cast({{ dbt.date_trunc("month", "termination_date") }} as date) and lower(primary_termination_category) = 'terminate_employee_involuntary') then 1 else 0 end) as churned_involuntary_employees,
        sum(case when date_month = cast({{ dbt.date_trunc("month", "end_employment_date") }} as date) then 1 else 0 end) as churned_workers
    from months_employed
    group by 1, 2
),

monthly_active_employee_metrics as (

    select date_month,
        source_relation,
        count(distinct employee_id) as active_employees,
        sum(case when gender is not null and lower(gender) = 'male' then 1 else 0 end) as active_male_employees,
        sum(case when gender is not null and lower(gender) = 'female' then 1 else 0 end) as active_female_employees,
        sum(case when gender is not null then 1 else 0 end) as active_known_gender_employees,
        avg(annual_currency_summary_primary_compensation_basis) as avg_employee_primary_compensation,
        avg(annual_currency_summary_total_base_pay) as avg_employee_base_pay,
        avg(annual_currency_summary_total_salary_and_allowances) as avg_employee_salary_and_allowances,
        avg(days_as_employee) as avg_days_as_employee
    from months_employed
    where cast(date_month as date) >= cast({{ dbt.date_trunc("month", "position_effective_date") }} as date)
        and (cast(date_month as date) <= cast({{ dbt.date_trunc("month", "end_employment_date") }} as date)
            or end_employment_date is null)
    group by 1, 2
),

monthly_active_worker_metrics as (
    
    select date_month,
        source_relation,
        count(distinct worker_id) as active_workers,
        avg(annual_currency_summary_primary_compensation_basis) as avg_worker_primary_compensation,
        avg(annual_currency_summary_total_base_pay) as avg_worker_base_pay,
        avg(annual_currency_summary_total_salary_and_allowances) as avg_worker_salary_and_allowances,
        avg(days_as_worker) as avg_days_as_worker
    from months_employed
    where (cast(date_month as date) >= cast({{ dbt.date_trunc("month", "position_effective_date") }} as date)
        and cast(date_month as date) <= cast({{ dbt.date_trunc("month", "end_employment_date") }} as date))
            or end_employment_date is null
    group by 1, 2
),

monthly_summary as (

    select 
        monthly_employee_metrics.date_month as metrics_month,
        monthly_employee_metrics.source_relation,
        monthly_employee_metrics.new_employees,
        monthly_employee_metrics.churned_employees,
        monthly_employee_metrics.churned_voluntary_employees,
        monthly_employee_metrics.churned_involuntary_employees,
        monthly_employee_metrics.churned_workers,
        monthly_active_employee_metrics.active_employees,
        monthly_active_employee_metrics.active_male_employees,
        monthly_active_employee_metrics.active_female_employees,
        monthly_active_worker_metrics.active_workers,
        monthly_active_employee_metrics.active_known_gender_employees,
        monthly_active_employee_metrics.avg_employee_primary_compensation,
        monthly_active_employee_metrics.avg_employee_base_pay,
        monthly_active_employee_metrics.avg_employee_salary_and_allowances,
        monthly_active_employee_metrics.avg_days_as_employee,
        monthly_active_worker_metrics.avg_worker_primary_compensation,
        monthly_active_worker_metrics.avg_worker_base_pay,
        monthly_active_worker_metrics.avg_worker_salary_and_allowances,
        monthly_active_worker_metrics.avg_days_as_worker
    from monthly_employee_metrics
    left join monthly_active_employee_metrics 
        on monthly_employee_metrics.date_month = monthly_active_employee_metrics.date_month
        and monthly_employee_metrics.source_relation = monthly_active_employee_metrics.source_relation
    left join monthly_active_worker_metrics
        on monthly_employee_metrics.date_month = monthly_active_worker_metrics.date_month
        and monthly_employee_metrics.source_relation = monthly_active_worker_metrics.source_relation
)

select *
from monthly_summary