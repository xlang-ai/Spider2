with story as (
    
    select * 
    from {{ var('story') }}

),

asana_user as (

    select * 
    from {{ var('user') }}
),

story_user as (
    select 
        story.*,
        asana_user.user_name as created_by_name
    from story
    join asana_user 
        on story.created_by_user_id = asana_user.user_id
),

split_comments as (

    select
        story_id,
        created_at,
        created_by_user_id,
        created_by_name,
        target_task_id,
            
        case when event_type = 'comment' then story_content 
        else null end as comment_content,

        case when event_type = 'system' then story_content 
        else 'comment' end as action_description
    
    from story_user

),


-- the next CTE uses this dictionary to parse the type of action out of the event descfription
{% set actions = {
    'added the name%': 'added name',
    'changed the name%': 'changed name',
    'removed the name': 'removed name',
    'added the description%': 'added description',
    'changed the description%': 'changed description',
    'removed the description': 'removed description',
    'added to%': 'added to project',
    'removed from%': 'removed from project',
    'assigned%': 'assigned',
    'unassigned%': 'unassigned',
    'changed the due date%': 'changed due date', 
    'changed the start date%due date%': 'changed due date',
    'changed the start date%': 'changed start date',
    'removed the due date%': 'removed due date',
    'removed the date range%': 'removed due date',
    'removed the start date': 'removed start date',
    'added subtask%': 'added subtask',
    'added%collaborator%': 'added collaborator',
    'moved%': 'moved to section',
    'duplicated task from%': 'duplicated this from other task',
    'marked%as a duplicate of this': 'marked other task as duplicate of this',
    'marked this a duplicate of%': 'marked as duplicate',
    'marked this task complete': 'completed',
    'completed this task': 'completed',
    'marked incomplete': 'marked incomplete',
    'marked this task as a milestone': 'marked as milestone',
    'unmarked this task as a milestone': 'unmarked as milestone',
    'marked this milestone complete': 'completed milestone',
    'completed this milestone': 'completed milestone',
    'attached%': 'attachment',
    'liked your comment': 'liked comment',
    'liked this task': 'liked task',
    'liked your attachment': 'liked attachment',
    'liked that you completed this task': 'liked completion',
    'completed the last task you were waiting on%': 'completed dependency',
    'added feedback to%': 'added feedback',
    'changed%to%': 'changed tag',
    'cleared%': 'cleared tag',
    'comment': 'comment',
    "have a task due on%": null 

} %}

parse_actions as (
    select
        story_id,
        target_task_id,
        created_at,
        created_by_user_id,
        created_by_name,
        comment_content,
        case 
        {%- for key, value in actions.items() %} 
        when action_description like '{{key}}' then '{{value}}' 
        {%- endfor %}
        else action_description end as action_taken,
        action_description
    
    from split_comments

),


final as (
    
    select * 
    from parse_actions

    -- remove actions you don't care about (set to null in the actions dictionary above)
    where action_taken is not null 

)


select * from final