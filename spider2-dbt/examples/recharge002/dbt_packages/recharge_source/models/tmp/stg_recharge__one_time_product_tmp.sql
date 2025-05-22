{{ config(enabled=var('recharge__one_time_product_enabled', True)) }}
select *
from {{ var('one_time_product') }}