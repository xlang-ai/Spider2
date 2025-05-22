{{ config(enabled=var('jira_using_sprints', True)) }}

select * 
from {{ var('sprint') }}