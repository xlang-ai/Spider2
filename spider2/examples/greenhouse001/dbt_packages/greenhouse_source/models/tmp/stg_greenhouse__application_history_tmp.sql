{{ config(enabled=var('greenhouse_using_app_history', True)) }}

select * from {{ var('application_history') }}
