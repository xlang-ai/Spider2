{{ config(enabled=var('greenhouse_using_job_office', True)) }}

select * from {{ var('office') }}
