WITH rgn_ttl AS (
    SELECT 
        MAX(total_usd) total_usd,
        region
    FROM (
        SELECT 
            r.name region,
            SUM(o.total_amt_usd) total_usd
        FROM 
            web_orders o
        JOIN 
            web_accounts a ON a.id = o.account_id
        JOIN 
            web_sales_reps s ON a.sales_rep_id = s.id
        JOIN 
            web_region r ON r.id = s.region_id
        GROUP BY 
            1
    ) x
    GROUP BY 
        2
    ORDER BY 
        1 DESC
    LIMIT 
        1
)
SELECT 
    COUNT(*) AS total_order
FROM 
    web_orders o
JOIN 
    web_accounts a ON a.id = o.account_id
JOIN 
    web_sales_reps s ON a.sales_rep_id = s.id
JOIN 
    web_region r ON r.id = s.region_id
WHERE 
    r.name = (
        SELECT 
            region
        FROM 
            rgn_ttl
    );
