with returned_orders as (
    select
        distinct order_id

    from {{ ref('stg_returned_orders') }}
)
select
    100 + ROW_NUMBER() OVER(order by null) as id
    ,*
from returned_orders