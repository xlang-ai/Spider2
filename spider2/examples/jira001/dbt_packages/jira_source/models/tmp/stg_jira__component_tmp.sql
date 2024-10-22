{{ config(enabled=var('jira_using_components', True)) }}

select * 
from {{ var('component') }}