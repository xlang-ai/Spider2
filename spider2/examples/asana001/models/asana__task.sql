with task as (
    select *
    from {{ var('task') }}
),

task_comments as (

    select *
    from {{ ref('int_asana__task_comments') }}
),

task_followers as (

    select *
    from {{ ref('int_asana__task_followers') }}
),

task_open_length as (

    select *
    from {{ ref('int_asana__task_open_length') }}
),

task_tags as (

    select *
    from {{ ref('int_asana__task_tags') }}
),

task_assignee as (

    select *
    from  {{ ref('int_asana__task_assignee') }}
    where has_assignee
),

task_projects as (

    select *
    from {{ ref('int_asana__task_projects') }}
),

subtask_parent as (

    select *
    from {{ ref('int_asana__subtask_parent') }}

),

task_first_modifier as (

    select *
    from {{ ref('int_asana__task_first_modifier') }}
),

task_join as (

    select
        task.*,
        concat('https://app.asana.com/0/0/', task.task_id) as task_link,
        task_assignee.assignee_name,
        task_assignee.assignee_email,

        task_open_length.days_open,
        task_open_length.is_currently_assigned,
        task_open_length.has_been_assigned,
        task_open_length.days_since_last_assignment, -- is null for never-assigned tasks
        task_open_length.days_since_first_assignment, -- is null for never-assigned tasks
        task_open_length.last_assigned_at,
        task_open_length.first_assigned_at,

        task_first_modifier.first_modifier_user_id,
        task_first_modifier.first_modifier_name,

        task_comments.conversation,
        coalesce(task_comments.number_of_comments, 0) as number_of_comments,
        task_followers.followers,
        coalesce(task_followers.number_of_followers, 0) as number_of_followers,
        task_tags.tags,
        coalesce(task_tags.number_of_tags, 0) as number_of_tags,

        task_projects.project_ids,
        task_projects.project_names,
        task_projects.projects_sections,
        task_projects.number_of_projects,

        subtask_parent.subtask_id is not null as is_subtask, -- parent id is in task.*
        subtask_parent.parent_task_name,
        subtask_parent.parent_assignee_user_id,
        subtask_parent.parent_assignee_name,
        subtask_parent.parent_due_date,
        subtask_parent.parent_created_at

    from
    task
    join task_open_length on task.task_id = task_open_length.task_id
    left join task_first_modifier on task.task_id = task_first_modifier.task_id

    left join task_comments on task.task_id = task_comments.task_id
    left join task_followers on task.task_id = task_followers.task_id
    left join task_tags on task.task_id = task_tags.task_id

    left join task_assignee on task.task_id = task_assignee.task_id

    left join subtask_parent on task.task_id = subtask_parent.subtask_id

    left join task_projects on task.task_id = task_projects.task_id

)

select * from task_join
