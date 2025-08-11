{{ config(enabled=var('marketo__enable_campaigns', False) and var('marketo__enable_programs', False)) }}

select *
from {{ var('program') }}
