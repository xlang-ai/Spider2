with issue as (

    select * 
    from {{ ref('jira__issue_enhanced') }}
    where project_id is not null
),

calculate_medians as (
    select 
        project_id,
        round(approx_quantile(case when resolved_at is not null then open_duration_seconds end, 0.5), 0) as median_close_time_seconds,
        round(approx_quantile(case when resolved_at is null then open_duration_seconds end, 0.5), 0) as median_age_currently_open_seconds,

        round(approx_quantile(case when resolved_at is not null then any_assignment_duration_seconds end, 0.5), 0) as median_assigned_close_time_seconds,
        round(approx_quantile(case when resolved_at is null then any_assignment_duration_seconds end, 0.5), 0) as median_age_currently_open_assigned_seconds

    from issue
    GROUP BY 1
),

-- grouping because the medians were calculated using window functions (except in postgres)
median_metrics as (

    select 
        project_id, 
        median_close_time_seconds, 
        median_age_currently_open_seconds,
        median_assigned_close_time_seconds,
        median_age_currently_open_assigned_seconds

    from calculate_medians
    group by 1,2,3,4,5
),


-- get appropriate counts + sums to calculate averages
project_issues as (
    select
        project_id,
        sum(case when resolved_at is not null then 1 else 0 end) as count_closed_issues,
        sum(case when resolved_at is null then 1 else 0 end) as count_open_issues,

        -- using the below to calculate averages

        -- assigned issues
        sum(case when resolved_at is null and assignee_user_id is not null then 1 else 0 end) as count_open_assigned_issues,
        sum(case when resolved_at is not null and assignee_user_id is not null then 1 else 0 end) as count_closed_assigned_issues,

        -- close time 
        sum(case when resolved_at is not null then open_duration_seconds else 0 end) as sum_close_time_seconds,
        sum(case when resolved_at is not null then any_assignment_duration_seconds else 0 end) as sum_assigned_close_time_seconds,

        -- age of currently open tasks
        sum(case when resolved_at is null then open_duration_seconds else 0 end) as sum_currently_open_duration_seconds,
        sum(case when resolved_at is null then any_assignment_duration_seconds else 0 end) as sum_currently_open_assigned_duration_seconds

    from issue

    group by 1
),

calculate_avg_metrics as (

    select
        project_id,
        count_closed_issues,
        count_open_issues,
        count_open_assigned_issues,

        case when count_closed_issues = 0 then 0 else
        round( cast(sum_close_time_seconds * 1.0 / count_closed_issues  as {{ dbt.type_numeric() }} ), 0) end as avg_close_time_seconds,

        case when count_closed_assigned_issues = 0 then 0 else
        round( cast(sum_assigned_close_time_seconds * 1.0 / count_closed_assigned_issues  as {{ dbt.type_numeric() }} ), 0) end as avg_assigned_close_time_seconds,

        case when count_open_issues = 0 then 0 else
        round( cast(sum_currently_open_duration_seconds * 1.0 / count_open_issues as {{ dbt.type_numeric() }} ), 0) end as avg_age_currently_open_seconds,

        case when count_open_assigned_issues = 0 then 0 else
        round( cast(sum_currently_open_assigned_duration_seconds * 1.0 / count_open_assigned_issues as {{ dbt.type_numeric() }} ), 0) end as avg_age_currently_open_assigned_seconds

    from project_issues
),

-- join medians and averages + convert to days
join_metrics as (

    select
        calculate_avg_metrics.*,

        -- there are 86400 seconds in a day
        round( cast(calculate_avg_metrics.avg_close_time_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as avg_close_time_days,
        round( cast(calculate_avg_metrics.avg_assigned_close_time_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as avg_assigned_close_time_days,
        round( cast(calculate_avg_metrics.avg_age_currently_open_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as avg_age_currently_open_days,
        round( cast(calculate_avg_metrics.avg_age_currently_open_assigned_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as avg_age_currently_open_assigned_days,

        median_metrics.median_close_time_seconds, 
        median_metrics.median_age_currently_open_seconds,
        median_metrics.median_assigned_close_time_seconds,
        median_metrics.median_age_currently_open_assigned_seconds,

        round( cast(median_metrics.median_close_time_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as median_close_time_days,
        round( cast(median_metrics.median_age_currently_open_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as median_age_currently_open_days,
        round( cast(median_metrics.median_assigned_close_time_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as median_assigned_close_time_days,
        round( cast(median_metrics.median_age_currently_open_assigned_seconds / 86400.0 as {{ dbt.type_numeric() }} ), 0) as median_age_currently_open_assigned_days
        
    from calculate_avg_metrics
    left join median_metrics using(project_id)
)

select * from join_metrics