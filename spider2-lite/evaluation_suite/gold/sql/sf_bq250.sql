WITH country_name AS (
  SELECT 'Singapore' AS value
),

last_updated AS (
  SELECT
    MAX("last_updated") AS value
  FROM GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM AS pop
    INNER JOIN country_name ON (pop."country_name" = country_name.value)
  WHERE "last_updated" < '2023-01-01'
),

aggregated_population AS (
  SELECT
    "geo_id",
    SUM("population") AS sum_population,
    ST_POINT("longitude_centroid", "latitude_centroid") AS centr  -- 计算每个 geo_id 的中心点
  FROM
    GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM AS pop
    INNER JOIN country_name ON (pop."country_name" = country_name.value)
    INNER JOIN last_updated ON (pop."last_updated" = last_updated.value)
  GROUP BY "geo_id", "longitude_centroid", "latitude_centroid"
),

population AS (
  SELECT
    SUM(sum_population) AS sum_population,
    ST_ENVELOPE(ST_UNION_AGG(centr)) AS boundingbox  -- 使用 ST_ENVELOPE 来代替 ST_CONVEXHULL
  FROM aggregated_population
),

hospitals AS (
  SELECT
    layer."geometry"
  FROM
    GEO_OPENSTREETMAP_WORLDPOP.GEO_OPENSTREETMAP.PLANET_LAYERS AS layer
    INNER JOIN population ON ST_INTERSECTS(population.boundingbox, ST_GEOGFROMWKB(layer."geometry"))
  WHERE
    layer."layer_code" IN (2110, 2120)
),

distances AS (
  SELECT
    pop."geo_id",
    pop."population",
    MIN(ST_DISTANCE(ST_GEOGFROMWKB(pop."geog"), ST_GEOGFROMWKB(hospitals."geometry"))) AS distance
  FROM
    GEO_OPENSTREETMAP_WORLDPOP.WORLDPOP.POPULATION_GRID_1KM AS pop
    INNER JOIN country_name ON pop."country_name" = country_name.value
    INNER JOIN last_updated ON pop."last_updated" = last_updated.value
    CROSS JOIN hospitals
  WHERE pop."population" > 0
  GROUP BY "geo_id", "population"
)

SELECT
  SUM(pd."population") AS population
FROM
  distances pd
CROSS JOIN population p
GROUP BY distance
ORDER BY distance DESC
LIMIT 1;
