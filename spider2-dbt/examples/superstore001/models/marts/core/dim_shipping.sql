with shipping as (
    select
        distinct ship_mode
    from {{ ref('stg_orders') }}
)
select
    100 + ROW_NUMBER() OVER(order by null) as id
    ,*
from shipping