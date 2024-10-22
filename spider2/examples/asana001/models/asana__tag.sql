with asana_tag as (

    select * 
    from {{ var('tag') }}
),

task_tag as (

    select * 
    from {{ var('task_tag') }}
),

task as (

    select *
    from {{ ref('asana__task') }}

    where is_completed and tags is not null

),

agg_tag as (

    select
        asana_tag.tag_id,
        asana_tag.tag_name,
        asana_tag.created_at,
        sum(case when not task.is_completed then 1 else 0 end) as number_of_open_tasks,
        sum(case when not task.is_completed and task.assignee_user_id is not null then 1 else 0 end) as number_of_assigned_open_tasks,
        sum(case when task.is_completed then 1 else 0 end) as number_of_tasks_completed,
        round(avg(case when task.is_completed then task.days_open else null end), 0) as avg_days_open,
        round(avg(case when task.is_completed then task.days_since_last_assignment else null end), 0) as avg_days_assigned


    from asana_tag 
    left join task_tag on asana_tag.tag_id = task_tag.tag_id
    left join task on task.task_id = task_tag.task_id

    group by 1,2,3
)

select * from agg_tag
