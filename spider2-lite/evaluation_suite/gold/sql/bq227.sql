WITH top5_categories AS (
  SELECT minor_category
  FROM `bigquery-public-data.london_crime.crime_by_lsoa`
  WHERE year = 2008
  GROUP BY minor_category
  ORDER BY SUM(value) DESC
  LIMIT 5
),

total_crimes_per_year AS (
  SELECT 
    year, 
    SUM(value) AS total_crimes_year
  FROM `bigquery-public-data.london_crime.crime_by_lsoa`
  GROUP BY year
),

top5_crimes_per_year AS (
  SELECT
    year,
    minor_category,
    SUM(value) AS total_crimes_category_year
  FROM `bigquery-public-data.london_crime.crime_by_lsoa`
  WHERE minor_category IN (SELECT minor_category FROM top5_categories)
  GROUP BY year, minor_category
)

SELECT
  t.year,
  ROUND(SUM(CASE WHEN t.minor_category = (SELECT minor_category FROM top5_categories LIMIT 1 OFFSET 0) THEN t.total_crimes_category_year ELSE 0 END) / y.total_crimes_year * 100, 2) AS `Category 1`,
  ROUND(SUM(CASE WHEN t.minor_category = (SELECT minor_category FROM top5_categories LIMIT 1 OFFSET 1) THEN t.total_crimes_category_year ELSE 0 END) / y.total_crimes_year * 100, 2) AS `Category 2`,
  ROUND(SUM(CASE WHEN t.minor_category = (SELECT minor_category FROM top5_categories LIMIT 1 OFFSET 2) THEN t.total_crimes_category_year ELSE 0 END) / y.total_crimes_year * 100, 2) AS `Category 3`,
  ROUND(SUM(CASE WHEN t.minor_category = (SELECT minor_category FROM top5_categories LIMIT 1 OFFSET 3) THEN t.total_crimes_category_year ELSE 0 END) / y.total_crimes_year * 100, 2) AS `Category 4`,
  ROUND(SUM(CASE WHEN t.minor_category = (SELECT minor_category FROM top5_categories LIMIT 1 OFFSET 4) THEN t.total_crimes_category_year ELSE 0 END) / y.total_crimes_year * 100, 2) AS `Category 5`
FROM
  top5_crimes_per_year t
JOIN
  total_crimes_per_year y ON t.year = y.year
GROUP BY
  t.year, y.total_crimes_year
ORDER BY
  t.year;
