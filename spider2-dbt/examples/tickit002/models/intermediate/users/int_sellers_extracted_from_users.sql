{{ config(materialized='view', bind=False) }}

with sales as (

    select * from {{ ref('stg_tickit__sales') }}

),

users as (

    select * from {{ ref('stg_tickit__users') }}

),

first_sale as (
    select min(CAST(sale_time AS DATE)) as first_sale_date, seller_id
    from sales
    group by seller_id
),

final as (

    select distinct
        u.user_id,
        u.username,
        cast((u.last_name || ', ' || u.first_name) as varchar(100)) as full_name,
        fs.first_sale_date,
        u.city,
        u.state,
        u.email,
        u.phone
    from 
        sales as s
            join users as u on u.user_id = s.seller_id
            join first_sale as fs on fs.seller_id = s.seller_id
    order by 
        user_id

)

select * from final
