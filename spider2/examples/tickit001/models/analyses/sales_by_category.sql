with sales as (

        select * from {{ ref('stg_tickit__sales') }}

),

events as (

        select * from {{ ref('stg_tickit__events') }}

),

categories as (

        select * from {{ ref('stg_tickit__categories') }}

),

final as (
        
    select
        c.cat_group,
        c.cat_name,
        count(s.price_paid) as total_transactions,
        sum(s.qty_sold) as total_tickets_sold,
        sum(s.price_paid) as total_sales,
        sum(s.commission) as total_commissions,
        sum(s.earnings) as total_earnings,
        round(total_sales / total_tickets_sold, 2) as avg_tickit_sale_price
    from
        sales s,
        events e,
        categories c
    where
        s.event_id = e.event_id
            and c.cat_id = e.cat_id
    group by
        cat_group,
        cat_name
    order by
        cat_group, 
        cat_name
    
)

select * from final