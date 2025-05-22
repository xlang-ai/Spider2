with customers as (
    select
        distinct customer_id
        ,customer_name
    from {{ ref('stg_orders') }}
)
select
    100 + ROW_NUMBER() OVER(order by null) as id
    ,*
from customers 