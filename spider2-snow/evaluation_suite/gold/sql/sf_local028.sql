SELECT 
    CASE delivery_month 
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February' 
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END as "Month",
    SUM(CASE WHEN delivery_year = 2016 THEN delivered_orders ELSE 0 END) as "2016",
    SUM(CASE WHEN delivery_year = 2017 THEN delivered_orders ELSE 0 END) as "2017",
    SUM(CASE WHEN delivery_year = 2018 THEN delivered_orders ELSE 0 END) as "2018"
FROM (
    SELECT 
        EXTRACT(YEAR FROM TO_TIMESTAMP("order_delivered_customer_date", 'YYYY-MM-DD HH24:MI:SS')) as delivery_year,
        EXTRACT(MONTH FROM TO_TIMESTAMP("order_delivered_customer_date", 'YYYY-MM-DD HH24:MI:SS')) as delivery_month,
        COUNT(*) as delivered_orders
    FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS 
    WHERE "order_status" = 'delivered' 
        AND "order_delivered_customer_date" IS NOT NULL 
        AND "order_delivered_customer_date" != ''
        AND EXTRACT(YEAR FROM TO_TIMESTAMP("order_delivered_customer_date", 'YYYY-MM-DD HH24:MI:SS')) IN (2016, 2017, 2018)
    GROUP BY delivery_year, delivery_month
) monthly_data
GROUP BY delivery_month
ORDER BY delivery_month