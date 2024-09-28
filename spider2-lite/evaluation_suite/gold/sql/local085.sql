WITH late_orders AS (
  SELECT
    o.employeeid,
    COUNT(o.orderid) AS late_order_count
  FROM
    orders o
  WHERE
    o.requireddate <= o.shippeddate
  GROUP BY
    o.employeeid
),
tot_orders AS (
  SELECT
    o.employeeid,
    COUNT(o.orderid) AS total_order_count
  FROM
    orders o
  GROUP BY
    o.employeeid
),
employee_performance AS (
  SELECT
    tot.employeeid,
    tot.total_order_count,
    lo.late_order_count,
    COALESCE(ROUND((lo.late_order_count * 100.0) / tot.total_order_count, 2), 0) AS late_order_percentage
  FROM
    tot_orders tot
  LEFT JOIN
    late_orders lo ON tot.employeeid = lo.employeeid
)
SELECT
  ep.employeeid,
  ep.late_order_count,
  ep.late_order_percentage
FROM
  employee_performance ep
WHERE
  ep.total_order_count > 50  -- Filter to include only employees with more than 50 orders
ORDER BY
  ep.late_order_percentage DESC
LIMIT 3;