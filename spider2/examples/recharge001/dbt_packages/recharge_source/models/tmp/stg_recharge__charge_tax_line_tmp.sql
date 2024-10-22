{{ config(enabled=var('recharge__charge_tax_line_enabled', True)) }}
select *
from {{ var('charge_tax_line') }}