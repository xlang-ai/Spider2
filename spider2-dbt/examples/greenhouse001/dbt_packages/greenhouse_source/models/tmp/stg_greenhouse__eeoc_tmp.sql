{{ config(enabled=var('greenhouse_using_eeoc', True)) }}

select * from {{ var('eeoc') }}
