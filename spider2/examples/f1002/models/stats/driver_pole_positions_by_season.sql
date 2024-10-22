WITH driver_pole_positions_by_season AS (
  SELECT
    d.driver_full_name,
    r.race_year as season,
    count(rs.grid) as pole_positions
  FROM {{ ref('stg_f1_dataset__results') }} rs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON rs.race_id = r.race_id
  JOIN {{ ref('stg_f1_dataset__drivers') }} d on rs.driver_id = d.driver_id
  WHERE rs.grid = 1
  GROUP BY d.driver_full_name, r.race_year
)

SELECT
  driver_full_name,
  season,
  pole_positions
FROM driver_pole_positions_by_season
ORDER BY season ASC


