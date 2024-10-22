{{ config(materialized='table', sort=['year', 'month'], dist='sale_id') }}

with sales as (

    select * from {{ ref('stg_tickit__sales') }}

),

dates as (

    select * from {{ ref('stg_tickit__dates') }}

),

final as (

    select
        row_number() over () as sale_id,
        d.year,
        d.month,
        d.qtr as quarter,
        sum(s.price_paid) as total_sales,
        sum(s.qty_sold) as total_tickets_sold,
        round(total_sales / total_tickets_sold, 2) as avg_tickit_sale_price,
        sum(s.commission) as total_commissions,
        sum(s.earnings) as total_earnings
    from 
        sales as s
            join dates as d on d.date_id = s.date_id
    group by
        year,
        month,
  		quarter
    order by 
        year,
        month,
  		quarter
  
)

select * from final