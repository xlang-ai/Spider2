{{ config(enabled=var('marketo__activity_delete_lead_enabled', True)) }}

select *
from {{ var('activity_delete_lead') }}
