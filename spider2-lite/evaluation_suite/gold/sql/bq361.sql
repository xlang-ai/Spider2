-- group each customer based on their cohort
WITH cohorts AS (
  SELECT
    user_id,
    DATE(created_at) AS order_date,
    DATE(DATE_TRUNC(FIRST_VALUE(created_at) OVER(PARTITION BY user_id ORDER BY created_at), month)) AS cohort
  FROM
    `bigquery-public-data.thelook_ecommerce.orders`
  WHERE 
    DATE(created_at) BETWEEN '2020-01-01' AND '2020-12-31'
),
-- calculate the number of months after the first month 
activity AS (
  SELECT
    user_id,
    cohort,
    DATE_DIFF(order_date, cohort, month) AS month_since_first_order
  FROM 
    cohorts
  WHERE 
    DATE(cohort) = '2020-01-01'
),
-- counting the number of unique users for each cohort and month_since_first_order
new_users AS ( 
  SELECT
    cohort,
    month_since_first_order,
    COUNT(DISTINCT user_id) AS new_user
  FROM
    activity
  GROUP BY
    cohort,
    month_since_first_order
),
-- calculate the total customer on each cohort
cohort_users AS (
  SELECT
    cohort,
    month_since_first_order,
    new_user,
    FIRST_VALUE(new_user) OVER(PARTITION BY cohort ORDER BY month_since_first_order) AS cohort_user
  FROM
    new_users
)
-- calculate the cohort users percentage
SELECT 
  cohort,
  month_since_first_order,
  new_user,
  cohort_user,
  new_user / cohort_user AS cohort_users_percentage
FROM 
  cohort_users
WHERE
  month_since_first_order > 0 -- Exclude January data (month 0)
ORDER BY
  cohort, 
  month_since_first_order;