WITH driver_podiums_by_season AS (
  SELECT
    d.driver_full_name,
    r.race_year as season,
    count(rs.position) as podiums
  FROM {{ ref('stg_f1_dataset__results') }} rs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON rs.race_id = r.race_id
  JOIN {{ ref('stg_f1_dataset__drivers') }} d on rs.driver_id = d.driver_id
  WHERE CAST(rs.position AS INTEGER) BETWEEN 1 AND 3
  GROUP BY d.driver_full_name, r.race_year
)

SELECT
  driver_full_name,
  season,
  podiums
FROM driver_podiums_by_season
ORDER BY season ASC


