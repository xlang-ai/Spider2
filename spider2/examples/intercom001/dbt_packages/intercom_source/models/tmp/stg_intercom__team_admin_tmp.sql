--To disable this model, set the intercom__using_team variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_team', True)) }}

select * 
from {{ var('team_admin') }}
