WITH table1 AS (
  SELECT
    created_at,
    session_id,
    sequence_number,
    CASE WHEN event_type = 'product' THEN CAST(REPLACE(uri, '/product/', '') AS INT) ELSE NULL END product_uri_id,
    LEAD(created_at) OVER (PARTITION BY session_id ORDER BY sequence_number) next_event
  FROM `bigquery-public-data.thelook_ecommerce.events` 
),

table2 AS (
  SELECT 
    p.category,
    COUNT(o.id) times_bought
  FROM `bigquery-public-data.thelook_ecommerce.products` p
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` o
    ON p.id = o.product_id
  GROUP BY 1
),

category_stats AS (
  SELECT 
    p.category,  
    COUNT(table1.product_uri_id) number_of_visits,
    ROUND(AVG(DATE_DIFF(table1.next_event, table1.created_at, SECOND) / 60), 2) avg_time_spent,
    table2.times_bought total_quantity_bought
  FROM table1
  LEFT JOIN bigquery-public-data.thelook_ecommerce.products p
    ON table1.product_uri_id = p.id
  LEFT JOIN table2
    ON p.category = table2.category
  WHERE table1.product_uri_id IS NOT NULL
  GROUP BY 1, 4
)

SELECT 
  CAST(avg_time_spent AS STRING) 
FROM category_stats
ORDER BY category_stats.total_quantity_bought DESC
LIMIT 1