{{ config(enabled=var('recharge__checkout_enabled', false)) }}

select *
from {{ var('checkout') }}