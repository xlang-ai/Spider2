SELECT
  month AS month_no,
  SUM(CASE WHEN a.year = '2016' THEN 1 ELSE 0 END) AS Year2016,
  SUM(CASE WHEN a.year = '2017' THEN 1 ELSE 0 END) AS Year2017,
  SUM(CASE WHEN a.year = '2018' THEN 1 ELSE 0 END) AS Year2018
FROM
(
  SELECT 
    customer_id,
    order_id,
    order_delivered_customer_date,
    order_status,
    strftime('%Y', order_delivered_customer_date) AS Year,
    strftime('%m', order_delivered_customer_date) AS Month
  FROM olist_orders
  WHERE order_status = 'delivered' 
    AND order_delivered_customer_date IS NOT NULL
  GROUP BY customer_id, order_id, order_delivered_customer_date
  ORDER BY order_delivered_customer_date ASC
) a
GROUP BY month
ORDER BY month_no ASC;