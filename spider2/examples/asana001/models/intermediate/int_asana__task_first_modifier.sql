with story as (

    select *
    from {{ ref('int_asana__task_story') }}
    where created_by_user_id is not null -- sometimes user id can be null in story. limit to ones with associated users
),

ordered_stories as (

    select 
        target_task_id,
        created_by_user_id,
        created_by_name,
        created_at,
        row_number() over ( partition by target_task_id order by created_at asc ) as nth_story
        
    from story

),

first_modifier as (

    select  
        target_task_id as task_id,
        created_by_user_id as first_modifier_user_id,
        created_by_name as first_modifier_name

    from ordered_stories 
    where nth_story = 1
)

select *
from first_modifier