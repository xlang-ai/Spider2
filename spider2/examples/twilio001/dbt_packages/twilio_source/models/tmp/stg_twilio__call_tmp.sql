--To disable this model, set the using_twilio_call variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_twilio_call', True)) }}

select {{ dbt_utils.star(source('twilio', 'call')) }}
from {{ var('call') }}
