with jira_user as (

    select *
    from {{ var('user') }}
),

user_metrics as (

    select *
    from {{ ref('int_jira__user_metrics') }}
),

issue as (

    select *
    from {{ ref('jira__issue_enhanced') }} 
),

user_project as (

    select 
        assignee_user_id,
        project_name

    from issue
    group by 1,2

),

agg_user_projects as (
    select 
        assignee_user_id,
        {{ fivetran_utils.string_agg( "project_name", "', '" ) }} as projects
    from user_project
    group by assignee_user_id
),


user_join as (

    select
        jira_user.*,
        agg_user_projects.projects, -- projects they've worked on issues for
        coalesce(user_metrics.count_closed_issues, 0) as count_closed_issues,
        coalesce(user_metrics.count_open_issues, 0) as count_open_issues,

        -- days
        user_metrics.avg_close_time_days,
        user_metrics.avg_age_currently_open_days,
        
        user_metrics.median_close_time_days,
        user_metrics.median_age_currently_open_days,

        -- seconds
        user_metrics.avg_close_time_seconds,
        user_metrics.avg_age_currently_open_seconds,
        
        user_metrics.median_close_time_seconds,
        user_metrics.median_age_currently_open_seconds

    from jira_user 
    left join user_metrics on jira_user.user_id = user_metrics.user_id
    left join agg_user_projects on jira_user.user_id = agg_user_projects.assignee_user_id
)

select * from user_join