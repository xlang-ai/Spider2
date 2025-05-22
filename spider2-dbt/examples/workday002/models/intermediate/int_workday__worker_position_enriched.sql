with worker_position_data as (

    select 
        *,
        {{ dbt.current_timestamp() }} as current_date
    from {{ ref('stg_workday__worker_position') }}
),

worker_position_data_enhanced as (

    select 
        worker_id,
        source_relation,
        position_id,
        employee_type, 
        business_title,
        fte_percent,
        position_start_date,
        position_end_date,
        position_effective_date,
        position_location,
        management_level_code,
        job_profile_id,
        case when position_end_date is null
            then {{ dbt.datediff('position_start_date', 'current_date', 'day') }}
            else {{ dbt.datediff('position_start_date', 'position_end_date', 'day') }}
        end as days_employed,
        row_number() over (partition by worker_id order by position_end_date desc) as row_number
    from worker_position_data
), 

worker_position_enriched as (

    select
        worker_position_data_enhanced.worker_id,
        worker_position_data_enhanced.source_relation,
        worker_position_data_enhanced.position_id, 
        worker_position_data_enhanced.business_title,
        worker_position_data_enhanced.job_profile_id, 
        worker_position_data_enhanced.employee_type,
        worker_position_data_enhanced.position_location,
        worker_position_data_enhanced.management_level_code,
        worker_position_data_enhanced.fte_percent,
        worker_position_data_enhanced.days_employed,
        worker_position_data_enhanced.position_start_date,
        worker_position_data_enhanced.position_end_date,
        worker_position_data_enhanced.position_effective_date
    from worker_position_data_enhanced
)

select * 
from worker_position_enriched