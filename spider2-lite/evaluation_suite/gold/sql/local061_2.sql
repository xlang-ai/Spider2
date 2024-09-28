WITH prod_sales_mo AS (
    SELECT cn.country_name AS c,
           s.prod_id AS p, 
           t.calendar_year AS y,
           t.calendar_month_number AS m,
           SUM(s.amount_sold) AS s
    FROM sales s
    JOIN customers c ON s.cust_id = c.cust_id
    JOIN times t ON s.time_id = t.time_id
    JOIN countries cn ON c.country_id = cn.country_id
    JOIN promotions p ON s.promo_id = p.promo_id
    JOIN channels ch ON s.channel_id = ch.channel_id
    WHERE p.promo_total_id = 1
      AND ch.channel_total_id = 1
      AND cn.country_name = 'France'
      AND t.calendar_year IN (2019, 2020, 2021)
    GROUP BY cn.country_name,
             s.prod_id, 
             t.calendar_year, 
             t.calendar_month_number
),
time_summary AS (
    SELECT DISTINCT calendar_year AS cal_y, 
                    calendar_month_number AS cal_m
    FROM times
    WHERE calendar_year IN (2019, 2020, 2021)
),
base_data AS (
    SELECT ts.cal_y AS y, 
           ts.cal_m AS m, 
           ps.c AS c, 
           ps.p AS p,
           COALESCE(ps.s, 0) AS s,
           (SELECT AVG(s) FROM prod_sales_mo ps2 
            WHERE ps2.c = ps.c AND ps2.p = ps.p 
              AND ps2.y = ps.y 
              AND ps2.m BETWEEN 1 AND 12) AS avg_s
    FROM time_summary ts
    LEFT JOIN prod_sales_mo ps ON ts.cal_y = ps.y AND ts.cal_m = ps.m
),
projected_data AS (
    SELECT c, p, y, m, s,
           CASE
              WHEN y = 2021 THEN ROUND(
                 (((SELECT s FROM base_data WHERE c = b.c AND p = b.p AND y = 2020 AND m = b.m) - (SELECT s FROM base_data WHERE c = b.c AND p = b.p AND y = 2019 AND m = b.m)) / 
                  (SELECT s FROM base_data WHERE c = b.c AND p = b.p AND y = 2019 AND m = b.m)) * 
                 (SELECT s FROM base_data WHERE c = b.c AND p = b.p AND y = 2020 AND m = b.m) + 
                 (SELECT s FROM base_data WHERE c = b.c AND p = b.p AND y = 2020 AND m = b.m)
              , 2)
              ELSE avg_s
           END AS nr
    FROM base_data b
),
monthly_avg_projection AS (
    SELECT 
        m AS month,
        AVG(nr * COALESCE((SELECT to_us FROM currency WHERE country = c AND year = y AND month = m), 1)) AS avg_monthly_projected_sales_in_usd
    FROM projected_data
    WHERE y = 2021
    GROUP BY m
),
ranked_months AS (
    SELECT month,
           avg_monthly_projected_sales_in_usd,
           ROW_NUMBER() OVER (ORDER BY avg_monthly_projected_sales_in_usd) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM monthly_avg_projection
),
median_month AS (
    SELECT avg_monthly_projected_sales_in_usd
    FROM ranked_months
    WHERE row_num = (total_count + 1) / 2 OR (total_count % 2 = 0 AND row_num IN (total_count / 2, total_count / 2 + 1))
)
SELECT AVG(avg_monthly_projected_sales_in_usd) AS median
FROM median_month;