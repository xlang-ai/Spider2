
SELECT
  incidents AS highest_monthly_thefts
FROM (
  SELECT
    year,
    EXTRACT(MONTH FROM date) AS month,
    COUNT(1) AS incidents,
    RANK() OVER (PARTITION BY year ORDER BY COUNT(1) DESC) AS ranking
  FROM
    `bigquery-public-data.chicago_crime.crime`
  WHERE
    primary_type = 'MOTOR VEHICLE THEFT'
    AND year = 2016
  GROUP BY
    year,
    month
)
WHERE
  ranking = 1
ORDER BY
  year DESC
LIMIT 1;