WITH "months" AS (
  SELECT 1 AS "month_num" UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
  SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL
  SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
),
"customers" AS (
  SELECT DISTINCT "customer_id"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
"txn_agg" AS (
  SELECT
    "customer_id",
    EXTRACT(month FROM CAST("txn_date" AS DATE)) AS "month_num",
    SUM(
      CASE
        WHEN LOWER("txn_type") LIKE '%deposit%' THEN "txn_amount"
        WHEN LOWER("txn_type") LIKE '%withdraw%' THEN - "txn_amount"
        ELSE 0
      END
    ) AS "month_sum"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
  WHERE CAST("txn_date" AS DATE) >= DATE_FROM_PARTS(2020,1,1)
    AND CAST("txn_date" AS DATE) < DATE_FROM_PARTS(2021,1,1)
  GROUP BY "customer_id", EXTRACT(month FROM CAST("txn_date" AS DATE))
),
"customer_months" AS (
  SELECT
    c."customer_id",
    m."month_num",
    COALESCE(t."month_sum", 0) AS "balance"
  FROM "customers" c
  CROSS JOIN "months" m
  LEFT JOIN "txn_agg" t
    ON t."customer_id" = c."customer_id"
   AND t."month_num" = m."month_num"
),
"month_stats" AS (
  SELECT
    "month_num",
    SUM(CASE WHEN "balance" > 0 THEN 1 ELSE 0 END) AS "positive_count",
    AVG("balance") AS "avg_balance"
  FROM "customer_months"
  GROUP BY "month_num"
)
SELECT
  h."month_num" AS "highest_month",
  h."positive_count" AS "highest_positive_count",
  h."avg_balance" AS "highest_avg_balance",
  l."month_num" AS "lowest_month",
  l."positive_count" AS "lowest_positive_count",
  l."avg_balance" AS "lowest_avg_balance",
  (h."avg_balance" - l."avg_balance") AS "average_difference"
FROM
  (SELECT * FROM "month_stats" ORDER BY "positive_count" DESC, "month_num" ASC LIMIT 1) h,
  (SELECT * FROM "month_stats" ORDER BY "positive_count" ASC, "month_num" ASC LIMIT 1) l;