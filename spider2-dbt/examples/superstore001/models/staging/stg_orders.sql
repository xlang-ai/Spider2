select
     row_id
    ,order_id
    ,order_date
    ,ship_date
    ,ship_mode
    ,customer_id
    ,customer_name
    ,segment
    ,country
    ,city
    ,state
    ,case when city = 'Burlington' and postal_code is null then '05401' else postal_code end as postal_code
    ,region
    ,product_id
    ,category as product_category
    ,subcategory as product_subcategory
    ,product_name
    ,sales
    ,quantity
    ,discount
    ,profit

from {{ source('superstore', 'orders') }}