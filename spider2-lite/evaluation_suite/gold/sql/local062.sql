-- profit by cust, prod, day, channel, promo
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
cust_daily_trans_amt AS (
   SELECT cust_id, 
          time_id, 
          channel_id, 
          SUM(dol_sold) AS cust_daily_trans_amt
   FROM cust_prod_mon_profit
   GROUP BY cust_id, time_id, channel_id
),
cust_purchase_cnt AS (
   SELECT cust_id, 
          COUNT(*) AS cust_purchase_cnt
   FROM cust_daily_trans_amt
   GROUP BY cust_id
),
cust_mon_profit AS (
   SELECT cust_id, 
          SUM(profit) AS cust_profit
   FROM cust_prod_mon_profit
   GROUP BY cust_id
),
-- Calculate min and max profit
min_max_p AS (
   SELECT MIN(cust_profit) AS min_p, 
          MAX(cust_profit) AS max_p
   FROM cust_mon_profit
),
-- Creating a simplified bucket system due to lack of `width_bucket` function
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
-- Aggregated data needed for each bucket
histo_data AS (
   SELECT bucket,
          (bucket * (max_p - min_p) / 10) AS top_end,
          COUNT(*) AS histo_count
   FROM cust_bucket, min_max_p
   GROUP BY bucket
),
-- Profitability of each product sold within each bucket
bucket_prod_profits AS (
   SELECT bucket, 
          prod_id, 
          SUM(profit) AS tot_prod_profit
   FROM cust_bucket
   JOIN cust_prod_mon_profit ON cust_bucket.cust_id = cust_prod_mon_profit.cust_id
   GROUP BY bucket, prod_id
),
-- Most and least profitable product by bucket
prod_profit AS (
   SELECT bucket,
          MIN(tot_prod_profit) AS min_profit_prod,
          MAX(tot_prod_profit) AS max_profit_prod
   FROM bucket_prod_profits
   GROUP BY bucket
)
-- Main query block
SELECT histo_data.bucket AS bucket, 
       histo_data.histo_count AS customer_count,
       prod_profit.min_profit_prod AS min_profit, 
       prod_profit.max_profit_prod AS max_profit
FROM histo_data
JOIN prod_profit ON histo_data.bucket = prod_profit.bucket
ORDER BY bucket ASC;