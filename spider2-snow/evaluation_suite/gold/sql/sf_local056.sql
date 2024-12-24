WITH result_table AS (
    SELECT 
        TO_CHAR(TO_TIMESTAMP(pm."payment_date"), 'MM') AS pay_mon,  -- Direct conversion to timestamp, no format needed
        cust."first_name" || ' ' || cust."last_name" AS fullname, 
        SUM(pm."amount") AS pay_amount 
    FROM 
        SQLITE_SAKILA.SQLITE_SAKILA.PAYMENT AS pm 
    JOIN 
        SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER AS cust 
    ON 
        pm."customer_id" = cust."customer_id" 
    GROUP BY 
        1, 
        2
), 
difference_per_mon AS (
    SELECT 
        rt.fullname, 
        ABS(rt.pay_amount - LAG(rt.pay_amount) OVER (PARTITION BY rt.fullname ORDER BY rt.pay_mon)) AS diff 
    FROM 
        result_table rt
), 
average_difference AS (
    SELECT 
        fullname, 
        AVG(diff) AS avg_diff
    FROM 
        difference_per_mon 
    WHERE 
        diff IS NOT NULL
    GROUP BY 
        fullname
)
SELECT 
    fullname
FROM 
    average_difference
ORDER BY 
    avg_diff DESC
LIMIT 1;
