{{ config(enabled=var('lever_using_requisitions', True)) }}

select * from {{ var('requisition_posting') }}
