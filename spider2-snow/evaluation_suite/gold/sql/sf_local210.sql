WITH completed_orders AS (
  SELECT
    o."order_id",
    o."store_id",
    o."order_created_month",
    o."order_created_year"
  FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
  WHERE o."order_created_year" = 2021
    AND o."order_created_month" IN (2,3)
    AND UPPER(TRIM(o."order_status")) = 'FINISHED'
)
SELECT
  h."hub_id" AS "hub_id",
  h."hub_name" AS "hub_name",
  CAST(SUM(CASE WHEN c."order_created_month" = 2 THEN 1 ELSE 0 END) AS INTEGER) AS "orders_february",
  CAST(SUM(CASE WHEN c."order_created_month" = 3 THEN 1 ELSE 0 END) AS INTEGER) AS "orders_march",
  (
    CAST(SUM(CASE WHEN c."order_created_month" = 3 THEN 1 ELSE 0 END) AS FLOAT)
    - CAST(SUM(CASE WHEN c."order_created_month" = 2 THEN 1 ELSE 0 END) AS FLOAT)
  ) / NULLIF(CAST(SUM(CASE WHEN c."order_created_month" = 2 THEN 1 ELSE 0 END) AS FLOAT), 0) AS "pct_increase"
FROM completed_orders c
JOIN DELIVERY_CENTER.DELIVERY_CENTER.STORES s
  ON c."store_id" = s."store_id"
JOIN DELIVERY_CENTER.DELIVERY_CENTER.HUBS h
  ON s."hub_id" = h."hub_id"
GROUP BY h."hub_id", h."hub_name"
HAVING
  SUM(CASE WHEN c."order_created_month" = 2 THEN 1 ELSE 0 END) > 0
  AND (
    (
      CAST(SUM(CASE WHEN c."order_created_month" = 3 THEN 1 ELSE 0 END) AS FLOAT)
      - CAST(SUM(CASE WHEN c."order_created_month" = 2 THEN 1 ELSE 0 END) AS FLOAT)
    ) / NULLIF(CAST(SUM(CASE WHEN c."order_created_month" = 2 THEN 1 ELSE 0 END) AS FLOAT), 0)
  ) > 0.2
ORDER BY "pct_increase" DESC, "hub_id" ASC;