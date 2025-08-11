{{
    config(
        materialized = 'table'
    )
}}

with issue as (

    select *
    from {{ ref('int_jira__issue_users') }}

),

project as (

    select * 
    from {{ var('project') }}
),

status as (

    select * 
    from {{ var('status') }}
),

status_category as (

    select * 
    from {{ var('status_category') }}
),

resolution as (

    select * 
    from {{ var('resolution') }}
),

{% if var('jira_using_priorities', True) %}
priority as (

    select * 
    from {{ var('priority') }}
),
{% endif %}

{% if var('jira_using_sprints', True) %}
issue_sprint as (

    select *
    from {{ ref('int_jira__issue_sprint') }}
),
{% endif %}

{% if var('jira_include_comments', True) %}
issue_comments as (

    select * 
    from {{ ref('int_jira__issue_comments') }}
),
{% endif %}

issue_assignments_and_resolutions as (
  
  select *
  from {{ ref('int_jira__issue_assign_resolution')}}

),

{% if var('jira_using_versions', True) %}
issue_versions as (

    select *
    from {{ ref('int_jira__issue_versions') }}
),
{% endif %}

join_issue as (

    select
        issue.* 

        ,project.project_name as project_name

        ,status.status_name as current_status
        ,status_category.status_category_name as current_status_category   
        ,resolution.resolution_name as resolution_type
        {% if var('jira_using_priorities', True) %}
        ,priority.priority_name as current_priority
	{% endif %}

        {% if var('jira_using_sprints', True) %}
        ,issue_sprint.current_sprint_id
        ,issue_sprint.current_sprint_name
        ,coalesce(issue_sprint.count_sprint_changes, 0) as count_sprint_changes
        ,issue_sprint.sprint_started_at
        ,issue_sprint.sprint_ended_at
        ,issue_sprint.sprint_completed_at
        ,coalesce(issue_sprint.sprint_started_at <= {{ dbt.current_timestamp_backcompat() }}
          and coalesce(issue_sprint.sprint_completed_at, {{ dbt.current_timestamp_backcompat() }}) >= {{ dbt.current_timestamp_backcompat() }}  
          , false) as is_active_sprint -- If sprint doesn't have a start date, default to false. If it does have a start date, but no completed date, this means that the sprint is active. The ended_at timestamp is irrelevant here.
        {% endif %}

        ,issue_assignments_and_resolutions.first_assigned_at
        ,issue_assignments_and_resolutions.last_assigned_at
        ,issue_assignments_and_resolutions.first_resolved_at

        {% if var('jira_using_versions', True) %}
        ,issue_versions.fixes_versions
        ,issue_versions.affects_versions
        {% endif %}

        {% if var('jira_include_comments', True) %}
        ,issue_comments.conversation
        ,coalesce(issue_comments.count_comments, 0) as count_comments
        {% endif %}
    
    from issue
    left join project on project.project_id = issue.project_id
    left join status on status.status_id = issue.status_id
    left join status_category on status.status_category_id = status_category.status_category_id
    left join resolution on resolution.resolution_id = issue.resolution_id
	{% if var('jira_using_priorities', True) %}
    left join priority on priority.priority_id = issue.priority_id
	{% endif %}
    left join issue_assignments_and_resolutions on issue_assignments_and_resolutions.issue_id = issue.issue_id

    {% if var('jira_using_versions', True) %}
    left join issue_versions on issue_versions.issue_id = issue.issue_id
    {% endif %}
    
    {% if var('jira_using_sprints', True) %}
    left join issue_sprint on issue_sprint.issue_id = issue.issue_id
    {% endif %}

    {% if var('jira_include_comments', True) %}
    left join issue_comments on issue_comments.issue_id = issue.issue_id
    {% endif %}
)

select * 
from join_issue
