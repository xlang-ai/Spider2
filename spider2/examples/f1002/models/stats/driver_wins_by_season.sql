WITH driver_wins_by_season AS (
  SELECT
    d.driver_full_name,
    r.race_year as season,
    count(rs.position) as wins
  FROM {{ ref('stg_f1_dataset__results') }} rs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON rs.race_id = r.race_id
  JOIN {{ ref('stg_f1_dataset__drivers') }} d on rs.driver_id = d.driver_id
  WHERE rs.position = 1
  GROUP BY d.driver_full_name, r.race_year
)

SELECT
  driver_full_name,
  season,
  wins
FROM driver_wins_by_season
ORDER BY season ASC


