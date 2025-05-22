{{ config(enabled=var('jira_using_priorities', True)) }}

select * from {{ var('priority') }}
