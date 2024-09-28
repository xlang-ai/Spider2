WITH payment_counts AS (
  SELECT
    raw.product_category_name,
    raw.payment_type,
    COUNT(raw.order_id) AS payment_count
  FROM (
    SELECT 
      p.product_category_name,
      p.order_id,
      p.payment_type
    FROM olist_order_payments p
    JOIN olist_orders o ON o.order_id = p.order_id
    JOIN olist_order_items i ON i.order_id = o.order_id
    JOIN olist_products_dataset p ON i.product_id = p.product_id
    GROUP BY 1, 2, 3
  ) raw
  GROUP BY 1, 2
),
ranked_payments AS (
  SELECT
    payment_counts.product_category_name,
    payment_counts.payment_type,
    payment_counts.payment_count,
    ROW_NUMBER() OVER (PARTITION BY payment_counts.product_category_name ORDER BY payment_counts.payment_count DESC) AS rn
  FROM payment_counts
),
top_payments AS (
  SELECT
    product_category_name,
    payment_type,
    payment_count
  FROM ranked_payments
  WHERE rn = 1
  ORDER BY payment_count DESC
  LIMIT 3
)
SELECT 
  top_payments.product_category_name AS Category_Name,
  top_payments.payment_count AS Payment_count
FROM top_payments
ORDER BY Payment_count DESC;