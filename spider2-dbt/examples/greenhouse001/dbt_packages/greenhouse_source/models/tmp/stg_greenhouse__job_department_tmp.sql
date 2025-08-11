{{ config(enabled=var('greenhouse_using_job_department', True)) }}

select * from {{ var('job_department') }}
