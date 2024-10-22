with regions as (
    select
        distinct region as region_name
    from {{ ref('stg_sales_managers') }}
)
select
    100 + ROW_NUMBER() OVER(order by null) as region_id
    ,*
from regions