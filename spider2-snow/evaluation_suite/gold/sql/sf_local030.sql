WITH CityPayments AS (
  SELECT
    C."customer_city",
    SUM(P."payment_value") AS total_payment,
    COUNT(DISTINCT O."order_id") AS delivered_order_count
  FROM
    "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS" AS O
    JOIN "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_CUSTOMERS" AS C
      ON O."customer_id" = C."customer_id"
    JOIN "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDER_PAYMENTS" AS P
      ON O."order_id" = P."order_id"
  WHERE
    O."order_status" = 'delivered'
  GROUP BY
    C."customer_city"
), Top5Cities AS (
  SELECT
    total_payment,
    delivered_order_count
  FROM CityPayments
  ORDER BY
    total_payment ASC
  LIMIT 5
)
SELECT
  AVG(total_payment),
  AVG(delivered_order_count)
FROM Top5Cities;