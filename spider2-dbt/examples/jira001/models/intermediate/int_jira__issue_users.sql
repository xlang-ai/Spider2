-- just grabs user attributes for issue assignees and reporters 

with issue as (

    -- including issue_id in here because snowflake for some reason ignores issue_id,
    -- so we'll just always pull it out and explicitly select it
    {% set except_columns = ["revised_parent_issue_id", "parent_issue_id", "issue_id"] %}

    select
        issue_id,
        coalesce(cast(revised_parent_issue_id as {{ dbt.type_string() }}), cast(parent_issue_id as {{ dbt.type_string() }})) as parent_issue_id,

        {{ dbt_utils.star(from=ref('int_jira__issue_type_parents'), 
                            except=except_columns) }}

    from {{ ref('int_jira__issue_type_parents') }}

),

-- user is a reserved keyword in AWS
jira_user as (

    select *
    from {{ var('user') }}
),

issue_user_join as (

    select
        issue.*,
        assignee.user_display_name as assignee_name,
        assignee.time_zone as assignee_timezone,
        assignee.email as assignee_email,
        reporter.email as reporter_email,
        reporter.user_display_name as reporter_name,
        reporter.time_zone as reporter_timezone

    from issue
    left join jira_user as assignee on issue.assignee_user_id = assignee.user_id 
    left join jira_user as reporter on issue.reporter_user_id = reporter.user_id

)

select * 
from issue_user_join