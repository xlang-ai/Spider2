WITH bounds AS (
  SELECT
    MIN(TO_DATE("txn_date",'YYYY-MM-DD')) AS "global_min_date",
    MAX(TO_DATE("txn_date",'YYYY-MM-DD')) AS "global_max_date"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
),
calendar AS (
  SELECT DATEADD('day', seq4(), b."global_min_date") AS "day"
  FROM bounds b,
       TABLE(GENERATOR(ROWCOUNT => 10000))
  WHERE seq4() <= DATEDIFF('day', b."global_min_date", b."global_max_date")
),
cust_bounds AS (
  SELECT
    "customer_id",
    MIN(TO_DATE("txn_date", 'YYYY-MM-DD')) AS "min_date",
    MAX(TO_DATE("txn_date", 'YYYY-MM-DD')) AS "max_date",
    DATE_TRUNC('MONTH', MIN(TO_DATE("txn_date", 'YYYY-MM-DD'))) AS "first_month"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
  GROUP BY "customer_id"
),
customer_days AS (
  SELECT
    cb."customer_id",
    c."day"
  FROM cust_bounds cb
  JOIN calendar c
    ON c."day" BETWEEN cb."min_date" AND cb."max_date"
),
daily_txn_agg AS (
  SELECT
    "customer_id",
    TO_DATE("txn_date", 'YYYY-MM-DD') AS "day",
    SUM(CASE WHEN "txn_type" = 'deposit' THEN "txn_amount" ELSE - "txn_amount" END) AS "daily_net"
  FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
  GROUP BY 1, 2
),
daily_balances AS (
  SELECT
    cd."customer_id",
    cd."day",
    COALESCE(dta."daily_net", 0) AS "daily_net",
    SUM(COALESCE(dta."daily_net", 0)) 
      OVER (PARTITION BY cd."customer_id" ORDER BY cd."day" 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "running_balance",
    ROW_NUMBER() OVER (PARTITION BY cd."customer_id" ORDER BY cd."day") AS "row_num"
  FROM customer_days cd
  LEFT JOIN daily_txn_agg dta
    ON cd."customer_id" = dta."customer_id"
   AND cd."day" = dta."day"
),
rolling_30d AS (
  SELECT
    "customer_id",
    "day",
    "running_balance",
    "row_num",
    AVG("running_balance") 
      OVER (PARTITION BY "customer_id" ORDER BY "day"
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS "avg_30d"
  FROM daily_balances
),
clamped_30d AS (
  SELECT
    r."customer_id",
    r."day",
    GREATEST(r."avg_30d", 0) AS "clamped_30d_avg",
    DATE_TRUNC('MONTH', r."day") AS "month_start"
  FROM rolling_30d r
  WHERE r."row_num" >= 30
    AND r."avg_30d" IS NOT NULL
),
monthly_customer_max AS (
  SELECT
    "customer_id",
    "month_start",
    MAX("clamped_30d_avg") AS "monthly_max_30d_avg"
  FROM clamped_30d
  GROUP BY 1, 2
),
monthly_customer_filtered AS (
  SELECT
    mcm."customer_id",
    mcm."month_start",
    mcm."monthly_max_30d_avg"
  FROM monthly_customer_max mcm
  JOIN cust_bounds cb
    ON mcm."customer_id" = cb."customer_id"
  WHERE mcm."month_start" <> cb."first_month"
)
SELECT
  TO_CHAR("month_start", 'YYYY-MM') AS "month",
  COALESCE(SUM("monthly_max_30d_avg"), 0) AS "monthly_total_max_30d_avg"
FROM monthly_customer_filtered
GROUP BY "month_start"
ORDER BY "month_start" ASC;