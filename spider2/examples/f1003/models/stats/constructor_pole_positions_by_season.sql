WITH constructor_pole_positions_by_season AS (
  SELECT
    c.constructor_name,
    r.race_year as season,
    count(rs.grid) as pole_positions
  FROM {{ ref('stg_f1_dataset__results') }} rs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON rs.race_id = r.race_id
  JOIN {{ ref('stg_f1_dataset__constructors') }} c on rs.constructor_id = c.constructor_id
  WHERE rs.grid = 1
  GROUP BY c.constructor_name, r.race_year
)

SELECT
  constructor_name,
  season,
  pole_positions
FROM constructor_pole_positions_by_season
ORDER BY season ASC


