with tasks as (

    select * 
    from {{ ref('asana__task') }}
    where assignee_user_id is not null

), 

agg_user_tasks as (

    select 
    assignee_user_id as user_id,
    sum(case when not is_completed then 1 else 0 end) as number_of_open_tasks,
    sum(case when is_completed then 1 else 0 end) as number_of_tasks_completed,
    sum(case when is_completed then days_since_last_assignment else 0 end) as days_assigned_this_user -- will divde later for avg

    from  tasks

    group by 1

),

final as (
    select
        agg_user_tasks.user_id,
        agg_user_tasks.number_of_open_tasks,
        agg_user_tasks.number_of_tasks_completed,
        nullif(agg_user_tasks.days_assigned_this_user, 0) * 1.0 / nullif(agg_user_tasks.number_of_tasks_completed, 0) as avg_close_time_days

    from 
    agg_user_tasks 
)

select * from final
