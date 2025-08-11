{{ config(enabled=var('jira_using_versions', True)) }}

select * 
from {{ var('version') }}