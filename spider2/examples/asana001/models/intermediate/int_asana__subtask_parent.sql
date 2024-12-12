with task_assignee as (

    select * 
    from  {{ ref('int_asana__task_assignee') }}

),


subtask_parent as (

    select
        subtask.task_id as subtask_id,
        parent.task_id as parent_task_id,
        parent.task_name as parent_task_name,
        parent.due_date as parent_due_date,
        parent.created_at as parent_created_at,
        parent.assignee_user_id as parent_assignee_user_id,
        parent.assignee_name as parent_assignee_name

    from task_assignee as parent 
    join task_assignee as subtask
        on cast(parent.task_id as string) = cast(subtask.parent_task_id as string)

)

select * from subtask_parent