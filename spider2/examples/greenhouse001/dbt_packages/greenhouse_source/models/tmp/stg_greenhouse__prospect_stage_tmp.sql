{{ config(enabled=var('greenhouse_using_prospects', True)) }}

select * from {{ var('prospect_stage') }}
