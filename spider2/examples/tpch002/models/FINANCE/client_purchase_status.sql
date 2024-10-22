select customer_id,
        customer_name,
        coalesce(purchase_total,0) as purchase_total,
        coalesce(lr.revenue_lost, 0) as return_total,
        coalesce(coalesce(purchase_total,0) - coalesce(lr.revenue_lost, 0), 0) as lifetime_value,
        (coalesce(lr.revenue_lost, 0)/coalesce(purchase_total,0))*100 as return_pct,
        case when coalesce(purchase_total, 0) = 0 then 'red' when (coalesce(lr.revenue_lost, 0)/coalesce(purchase_total,0))*100 <= 25 then 'green' when (coalesce(lr.revenue_lost, 0)/coalesce(purchase_total,0))*100 <= 50 then 'yellow' when (coalesce(lr.revenue_lost, 0)/coalesce(purchase_total,0))*100 <= 75 then 'orange' when (coalesce(lr.revenue_lost, 0)/coalesce(purchase_total,0))*100 <= 100 then 'red' end as customer_status

    from 
        (select c.c_custkey as customer_id,
            c.c_name as customer_name,
            round(sum(customer_cost), 2) as purchase_total
        from {{ source('TPCH_SF1', 'customer') }} c
            left join {{ ref('order_line_items') }} oli
                on c.c_custkey = oli.customer_id
            where item_status != 'R'
            group by c_custkey, c_name
        order by c_custkey) co
        left join 
            {{ ref('lost_revenue') }} lr
                on co.customer_id = lr.c_custkey