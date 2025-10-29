WITH MonthlyPayments AS (
  SELECT
    "customer_id",
    TO_VARCHAR(TO_TIMESTAMP("payment_date"), 'YYYY-MM') AS "payment_month",
    SUM("amount") AS "monthly_total"
  FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."PAYMENT"
  GROUP BY "customer_id", "payment_month"
), MonthlyChanges AS (
  SELECT
    "customer_id",
    ABS("monthly_total" - LAG("monthly_total", 1) OVER (PARTITION BY "customer_id" ORDER BY "payment_month")) AS "change"
  FROM MonthlyPayments
), AvgMonthlyChange AS (
  SELECT
    "customer_id",
    AVG("change") AS "avg_change"
  FROM MonthlyChanges
  WHERE "change" IS NOT NULL
  GROUP BY "customer_id"
)
SELECT
  T1."first_name" || ' ' || T1."last_name"
FROM "SQLITE_SAKILA"."SQLITE_SAKILA"."CUSTOMER" AS T1
JOIN AvgMonthlyChange AS T2
  ON T1."customer_id" = T2."customer_id"
ORDER BY T2."avg_change" DESC
LIMIT 1;