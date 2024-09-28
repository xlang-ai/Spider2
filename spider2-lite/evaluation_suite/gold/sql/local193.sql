WITH
    first_order AS (
        SELECT q1.*
        FROM (
            SELECT 
                p.customer_id,
                p.payment_date,
                ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS row_num
            FROM 
                payment p
        ) q1
        WHERE 
            q1.row_num = 1
    ),
    interval_sales AS (
        SELECT 
            fo.customer_id,
            (SELECT SUM(p2.amount)
             FROM payment p2
             WHERE p2.customer_id = fo.customer_id
               AND p2.payment_date BETWEEN fo.payment_date AND DATE(fo.payment_date, '+7 days')) AS first7_sales,
            (SELECT SUM(p2.amount)
             FROM payment p2
             WHERE p2.customer_id = fo.customer_id
               AND p2.payment_date BETWEEN fo.payment_date AND DATE(fo.payment_date, '+14 days')) AS first14_sales,
            (SELECT SUM(p2.amount)
             FROM payment p2
             WHERE p2.customer_id = fo.customer_id) AS LTV
        FROM 
            first_order fo
    )
SELECT 
    (ROUND(AVG(i_s.first7_sales / i_s.LTV * 100), 2) || '%') AS avg_first7_percent,
    (ROUND(AVG(i_s.first14_sales / i_s.LTV * 100), 2) || '%') AS avg_first14_percent,
    ROUND(AVG(i_s.LTV), 2) AS avg_ltv
FROM 
    interval_sales i_s
WHERE 
    i_s.LTV > 0;
