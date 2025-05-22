{{ config(enabled=var('lever_using_posting_tag', True)) }}


select * from {{ var('posting_tag') }}
