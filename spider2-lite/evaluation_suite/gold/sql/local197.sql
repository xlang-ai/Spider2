WITH result_table AS (
  SELECT 
    strftime('%m', pm.payment_date) AS pay_mon, 
    customer_id,
    COUNT(pm.amount) AS pay_countpermon, 
    SUM(pm.amount) AS pay_amount 
  FROM 
    payment AS pm 
  GROUP BY 
    pay_mon, 
    customer_id
), 
top10_customer AS (
  SELECT 
    customer_id,
    SUM(tb.pay_amount) AS total_payments 
  FROM 
    result_table AS tb 
  GROUP BY 
    customer_id
  ORDER BY 
    SUM(tb.pay_amount) DESC 
  LIMIT 
    10
), 
difference_per_mon AS (
  SELECT 
    pay_mon AS month_number, 
    pay_mon AS month, 
    tb.pay_countpermon, 
    tb.pay_amount, 
    ABS(tb.pay_amount - LAG(tb.pay_amount) OVER (PARTITION BY tb.customer_id)) AS diff 
  FROM 
    result_table tb 
    JOIN top10_customer top ON top.customer_id = tb.customer_id
) 
SELECT 
  month, 
  ROUND(max_diff, 2) AS max_diff 
FROM (
  SELECT 
    month, 
    diff, 
    month_number, 
    MAX(diff) OVER (PARTITION BY month) AS max_diff 
  FROM 
    difference_per_mon
) AS max_per_mon 
WHERE 
  diff = max_diff 
ORDER BY 
  max_diff DESC 
LIMIT 
  1;
