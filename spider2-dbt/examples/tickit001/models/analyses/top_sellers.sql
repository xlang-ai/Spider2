with sales as (

        select * from {{ ref('stg_tickit__sales') }}

),

sellers as (

    select * from {{ ref('int_sellers_extracted_from_users') }}

),

q1 as (

    select
        seller_id,
        count(price_paid) as total_transactions,
        sum(price_paid) as total_sales,
        sum(qty_sold) as total_tickets_sold,
        sum(commission) as total_commissions,
        sum(earnings) as total_earnings
    from
        sales
    group by
        seller_id

),

q2 as (

    select
        *,
        ntile(1000) over (
            order by total_sales desc
        ) as percentile,
        round(total_sales / total_tickets_sold, 2) as avg_price_per_tickit_sold,
        round(total_earnings / total_tickets_sold, 2) as avg_earnings_per_ticket_sold
    from
        q1

),

final as (
        
    select
        se.username,
        se.state,
        q2.total_transactions,
        q2.total_sales,
        q2.total_tickets_sold,
        q2.total_commissions,
        q2.total_earnings,
        q2.avg_price_per_tickit_sold,
        q2.avg_earnings_per_ticket_sold
    from
        q2,
        sellers se
    where
        q2.seller_id = se.user_id
            and q2.percentile = 1
    order by
        q2.total_sales desc

)

select * from final