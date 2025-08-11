WITH driver_fastest_laps_by_season AS (
  SELECT
    d.driver_full_name,
    r.race_year as season,
    count(rs.rank) AS fastest_laps
  FROM {{ ref('stg_f1_dataset__results') }} rs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON rs.race_id = r.race_id
  JOIN {{ ref('stg_f1_dataset__drivers') }} d on rs.driver_id = d.driver_id
  WHERE rs.rank = 1
  GROUP BY d.driver_full_name, r.race_year
)

SELECT
  driver_full_name,
  season,
  fastest_laps
FROM driver_fastest_laps_by_season
ORDER BY season ASC

