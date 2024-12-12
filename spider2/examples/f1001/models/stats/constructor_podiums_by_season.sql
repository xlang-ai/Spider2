WITH constructor_podiums_by_season AS (
  SELECT
    c.constructor_name,
    r.race_year as season,
    count(rs.position) as podiums
  FROM {{ ref('stg_f1_dataset__results') }} rs
  JOIN {{ ref('stg_f1_dataset__races') }} r ON rs.race_id = r.race_id
  JOIN {{ ref('stg_f1_dataset__constructors') }} c on rs.constructor_id = c.constructor_id
  WHERE CAST(rs.position AS INTEGER) BETWEEN 1 AND 3
  GROUP BY c.constructor_name, r.race_year
)

SELECT
  constructor_name,
  season,
  podiums
FROM constructor_podiums_by_season
ORDER BY season ASC
