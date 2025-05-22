WITH constructor_points AS (
  SELECT
    c.constructor_name,
    r.race_year as season,
    max(cs.points) AS total_points
  FROM {{ ref('stg_f1_dataset__constructor_standings') }} cs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON cs.raceId = r.race_id
  JOIN {{ ref('stg_f1_dataset__constructors') }} c on cs.constructorId = c.constructor_id
  GROUP BY c.constructor_name, r.race_year
)

SELECT
  constructor_name,
  season,
  total_points
FROM constructor_points
ORDER BY season ASC
