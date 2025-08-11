{{ config(enabled=var('marketo__enable_campaigns', False)) }}

select *
from {{ var('campaign') }}
