WITH country_name AS (
  SELECT 'Singapore' AS value
),

last_updated AS (
  SELECT
    MAX(last_updated) AS value
  FROM `spider2-public-data.worldpop.population_grid_1km` AS pop
    INNER JOIN country_name ON (pop.country_name = country_name.value)
  WHERE last_updated < '2023-01-01'
),

population AS (
  SELECT
    SUM(sum_population) AS sum_population,
    ST_CONVEXHULL(st_union_agg(centr)) AS boundingbox
  FROM (
    SELECT
      SUM(population) AS sum_population,
      ST_CENTROID_AGG(ST_GEOGPOINT(longitude_centroid, latitude_centroid)) AS centr
    FROM
      `spider2-public-data.worldpop.population_grid_1km` AS pop
      INNER JOIN country_name ON (pop.country_name = country_name.value)
      INNER JOIN last_updated ON (pop.last_updated = last_updated.value)
    GROUP BY geo_id
  )
),

hospitals AS (
  SELECT
    layer.geometry
  FROM
    `spider2-public-data.geo_openstreetmap.planet_layers` AS layer
    INNER JOIN population ON ST_INTERSECTS(population.boundingbox, layer.geometry)
  WHERE
    layer.layer_code in (2110, 2120)
),

distances AS (
  SELECT
    pop.geo_id,
    pop.population,
    MIN(ST_DISTANCE(pop.geog, hospitals.geometry)) AS distance
  FROM
    `spider2-public-data.worldpop.population_grid_1km` AS pop
      INNER JOIN country_name ON pop.country_name = country_name.value
      INNER JOIN last_updated ON pop.last_updated = last_updated.value  
      CROSS JOIN hospitals
  WHERE pop.population > 0
  GROUP BY geo_id, population
)

SELECT
  SUM(pd.population) AS population
FROM
  distances pd
CROSS JOIN population p
GROUP BY distance
ORDER BY distance DESC
LIMIT 1