SELECT
  "Month" AS "month_no",
  SUM(CASE WHEN A."Year" = '2016' THEN 1 ELSE 0 END) AS "Year2016",
  SUM(CASE WHEN A."Year" = '2017' THEN 1 ELSE 0 END) AS "Year2017",
  SUM(CASE WHEN A."Year" = '2018' THEN 1 ELSE 0 END) AS "Year2018"
FROM
(
  SELECT 
    "customer_id",
    "order_id",
    "order_delivered_customer_date",
    "order_status",
    TO_VARCHAR(TO_DATE("order_delivered_customer_date"), 'YYYY') AS "Year",
    TO_VARCHAR(TO_DATE("order_delivered_customer_date"), 'MM') AS "Month"
  FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS
  WHERE "order_status" = 'delivered' 
    AND "order_delivered_customer_date" IS NOT NULL
    AND "order_delivered_customer_date" <> ''
  GROUP BY "customer_id", "order_id", "order_delivered_customer_date", "order_status"
  ORDER BY "order_delivered_customer_date" ASC
) A
GROUP BY "Month"
ORDER BY "month_no" ASC;