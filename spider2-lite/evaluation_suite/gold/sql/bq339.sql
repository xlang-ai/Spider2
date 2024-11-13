WITH monthly_totals AS (
  SELECT
    SUM(CASE WHEN subscriber_type = 'Customer' THEN duration_sec / 60 ELSE NULL END) AS customer_minutes_sum,
    SUM(CASE WHEN subscriber_type = 'Subscriber' THEN duration_sec / 60 ELSE NULL END) AS subscriber_minutes_sum,
    EXTRACT(MONTH FROM end_date) AS end_month
  FROM
    `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
  WHERE
    EXTRACT(YEAR FROM end_date) = 2017
  GROUP BY
    end_month
),

cumulative_totals AS (
  SELECT
    end_month,
    SUM(customer_minutes_sum) OVER (ORDER BY end_month ROWS UNBOUNDED PRECEDING) / 1000 AS cumulative_minutes_cust,
    SUM(subscriber_minutes_sum) OVER (ORDER BY end_month ROWS UNBOUNDED PRECEDING) / 1000 AS cumulative_minutes_sub
  FROM
    monthly_totals
),

differences AS (
  SELECT
    end_month,
    ABS(cumulative_minutes_cust - cumulative_minutes_sub) AS abs_diff
  FROM
    cumulative_totals
)

SELECT
  end_month
FROM
  differences
ORDER BY
  abs_diff DESC
LIMIT 1;