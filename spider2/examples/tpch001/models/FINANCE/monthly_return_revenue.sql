
SELECT 
        date_trunc('month', order_date) as MONTH,
        ROUND(SUM(customer_cost), 2) AS RETURN_TOTAL,
        COUNT(distinct order_id) as ORDERS_WITH_RETURNS,
        COUNT(CONCAT(order_id,line_id)) as ITEMS_RETURNED
FROM 
        {{ ref('order_line_items') }}
WHERE 
        item_status = 'R' 
GROUP BY 
        month
ORDER BY
        month