with task as (
    
    select *
    from {{ var('task') }}

),

story as (

    select * 
    from {{ ref('int_asana__task_story') }}

),

assignments as (
    
    select 
    target_task_id as task_id,
    min(created_at) as first_assigned_at,
    max(created_at) as last_assigned_at -- current assignment

    from story
    where action_taken = 'assigned'

    group by 1

),


open_assigned_length as (

    {% set open_until = 'task.completed_at' if 'task.is_completed' is true else dbt.current_timestamp_backcompat() %}

    select
        task.task_id,
        task.is_completed,
        task.completed_at,
        task.assignee_user_id is not null as is_currently_assigned,
        assignments.task_id is not null as has_been_assigned,
        assignments.last_assigned_at as last_assigned_at,
        assignments.first_assigned_at as first_assigned_at,
        {{ dbt.datediff('task.created_at', open_until, 'day') }} as days_open,

        -- if the task is currently assigned, this is the time it has been assigned to this current user.
        {{ dbt.datediff('assignments.last_assigned_at', open_until, 'day') }} as days_since_last_assignment,

        {{ dbt.datediff('assignments.first_assigned_at', open_until, 'day') }} as days_since_first_assignment
        

    from task
    left join assignments 
        on task.task_id = assignments.task_id

)


select * from open_assigned_length