with sales as (

        select * from {{ ref('stg_tickit__sales') }}

),

events as (

        select * from {{ ref('stg_tickit__events') }}

),

categories as (

        select * from {{ ref('stg_tickit__categories') }}

),

q1 as (

    select
        event_id,
        count(price_paid) as total_transactions,
        sum(price_paid) as total_sales,
        sum(qty_sold) as total_tickets_sold,
        sum(commission) as total_commissions,
        sum(earnings) as total_earnings
    from
        sales
    group by
        event_id

),

q2 as (

    select
        *,
        ntile(100) over (
            order by total_sales desc
        ) as percentile
    from
        q1

),

final as (
        
    select
        e.event_name,
        c.cat_name,
        q2.total_transactions,
        q2.total_sales,
        q2.total_tickets_sold,
        q2.total_commissions,
        q2.total_earnings,
        round(q2.total_sales / q2.total_tickets_sold, 2) as avg_tickit_sale_price
    from
        q2,
        events e,
        categories c
    where
        q2.event_id = e.event_id
            and c.cat_id = e.cat_id
            and q2.percentile = 1
    order by 
        total_sales desc

)

select * from final