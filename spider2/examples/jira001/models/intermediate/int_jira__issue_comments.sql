{{ config(enabled=var('jira_include_comments', True)) }}

with comment as (

    select *
    from {{ var('comment') }}

    order by issue_id, created_at asc

),

-- user is a reserved keyword in AWS 
jira_user as (

    select *
    from {{ var('user') }}
),

agg_comments as (

    select 
    comment.issue_id,
    {{ fivetran_utils.string_agg( "comment.created_at || '  -  ' || jira_user.user_display_name || ':  ' || comment.body", "'\\n'" ) }} as conversation,
    count(comment.comment_id) as count_comments

    from
    comment 
    join jira_user on comment.author_user_id = jira_user.user_id

    group by 1
)

select * from agg_comments