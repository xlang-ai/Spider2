WITH cust_prod_mon_profit AS (
   SELECT s.cust_id, 
          s.prod_id, 
          s.time_id,
          s.channel_id, 
          s.promo_id,
          s.quantity_sold * (c.unit_price - c.unit_cost) AS profit,
          s.amount_sold AS dol_sold, 
          c.unit_price AS price, 
          c.unit_cost AS cost
   FROM sales s
   JOIN costs c ON s.prod_id = c.prod_id
               AND s.time_id = c.time_id
               AND s.promo_id = c.promo_id
               AND s.channel_id = c.channel_id
   WHERE s.cust_id IN (
         SELECT cust_id FROM customers
         WHERE country_id = 52770
   )
   AND s.time_id IN (
         SELECT time_id FROM times
         WHERE calendar_month_desc = '2021-12'
   )
),
cust_mon_profit AS (
   SELECT cust_id, 
          SUM(profit) AS cust_profit
   FROM cust_prod_mon_profit
   GROUP BY cust_id
),
min_max_p AS (
   SELECT MIN(cust_profit) AS min_p, 
          MAX(cust_profit) AS max_p
   FROM cust_mon_profit
),
cust_bucket AS (
   SELECT cust_id, cust_profit,
          CASE
             WHEN cust_profit <= min_p + (max_p - min_p) / 10 THEN 1
             WHEN cust_profit <= min_p + 2 * (max_p - min_p) / 10 THEN 2
             WHEN cust_profit <= min_p + 3 * (max_p - min_p) / 10 THEN 3
             WHEN cust_profit <= min_p + 4 * (max_p - min_p) / 10 THEN 4
             WHEN cust_profit <= min_p + 5 * (max_p - min_p) / 10 THEN 5
             WHEN cust_profit <= min_p + 6 * (max_p - min_p) / 10 THEN 6
             WHEN cust_profit <= min_p + 7 * (max_p - min_p) / 10 THEN 7
             WHEN cust_profit <= min_p + 8 * (max_p - min_p) / 10 THEN 8
             WHEN cust_profit <= min_p + 9 * (max_p - min_p) / 10 THEN 9
             ELSE 10
          END AS bucket
   FROM cust_mon_profit, min_max_p
),
bucket_prod_profits AS (
   SELECT bucket, 
          prod_id, 
          SUM(profit) AS tot_prod_profit
   FROM cust_bucket
   JOIN cust_prod_mon_profit ON cust_bucket.cust_id = cust_prod_mon_profit.cust_id
   GROUP BY bucket, prod_id
),
prod_profit AS (
   SELECT bucket,
          MAX(tot_prod_profit) AS max_profit_prod
   FROM bucket_prod_profits
   GROUP BY bucket
)
-- Main query block
SELECT bucket, 
       MAX(max_profit_prod) AS max_profit
FROM prod_profit
GROUP BY bucket
ORDER BY max_profit DESC
LIMIT 3;