with task as (

    select *
    from {{ ref('asana__task') }}

),

project as (

    select * 
    from {{ var('project') }}

),

project_task as (

    select * 
    from {{ var('project_task') }}
),

project_task_history as (

    select
        project.project_id,
        task.task_id,
        task.is_completed as task_is_completed,
        task.assignee_user_id as task_assignee_user_id,
        task.days_open as task_days_open,
        task.days_since_last_assignment as task_days_assigned_current_user

    from project
    left join project_task 
        on project.project_id = project_task.project_id
    left join task 
        on project_task.task_id = task.task_id

),

agg_proj_tasks as (

    select 
    project_id,
    sum(case when not task_is_completed then 1 else 0 end) as number_of_open_tasks,
    sum(case when not task_is_completed and task_assignee_user_id is not null then 1 else 0 end) as number_of_assigned_open_tasks,
    sum(case when task_is_completed then 1 else 0 end) as number_of_tasks_completed,
    sum(case when task_is_completed and task_assignee_user_id is not null then 1 else 0 end) as number_of_assigned_tasks_completed,
    sum(case when task_is_completed then task_days_open else 0 end) as total_days_open,
    sum(case when task_is_completed then task_days_assigned_current_user else 0 end) as total_days_assigned_last_user -- will divde later for avg

    from  project_task_history

    group by 1

),

final as (

    select
        agg_proj_tasks.*,
        round(nullif(total_days_open, 0) * 1.0 / nullif(number_of_tasks_completed, 0), 0) as avg_close_time_days,
        round(nullif(total_days_assigned_last_user, 0) * 1.0 / nullif(number_of_assigned_tasks_completed, 0), 0) as avg_close_time_assigned_days

    from agg_proj_tasks
    
)

select * from final
