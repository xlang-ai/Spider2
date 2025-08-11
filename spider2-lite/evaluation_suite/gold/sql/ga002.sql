WITH
Params AS (
  SELECT 'Google Red Speckled Tee' AS selected_product
),
DateRanges AS (
  SELECT '20201101' AS start_date, '20201130' AS end_date, '202011' AS period UNION ALL
  SELECT '20201201', '20201231', '202012' UNION ALL
  SELECT '20210101', '20210131', '202101'
),
PurchaseEvents AS (
  SELECT
    period,
    user_pseudo_id,
    items
  FROM
    DateRanges
  JOIN
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    ON _TABLE_SUFFIX BETWEEN start_date AND end_date
  WHERE
    event_name = 'purchase'
),
ProductABuyers AS (
  SELECT DISTINCT
    period,
    user_pseudo_id
  FROM
    Params,
    PurchaseEvents,
    UNNEST(items) AS items
  WHERE
    items.item_name = selected_product
),
TopProducts AS (
  SELECT
    pe.period,
    items.item_name AS item_name,
    SUM(items.quantity) AS item_quantity
  FROM
    Params,
    PurchaseEvents pe,
    UNNEST(items) AS items
  WHERE
    user_pseudo_id IN (SELECT user_pseudo_id FROM ProductABuyers pb WHERE pb.period = pe.period)
    AND items.item_name != selected_product
  GROUP BY
    pe.period, items.item_name
),
TopProductPerPeriod AS (
  SELECT
    period,
    item_name,
    item_quantity
  FROM (
    SELECT
      period,
      item_name,
      item_quantity,
      RANK() OVER (PARTITION BY period ORDER BY item_quantity DESC) AS rank
    FROM
      TopProducts
  )
  WHERE
    rank = 1
)
SELECT
  period,
  item_name,
  item_quantity
FROM
  TopProductPerPeriod
ORDER BY
  period;
