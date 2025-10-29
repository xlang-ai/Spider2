WITH admin_candidates AS (
  SELECT
    pf."osm_id",
    pf."geometry",
    pf."osm_timestamp"
  FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES AS pf,
       LATERAL FLATTEN(INPUT => pf."all_tags") tag
  WHERE pf."feature_type" = 'multipolygons'
    AND tag.value:"key"::STRING = 'boundary'
    AND LOWER(TRIM(tag.value:"value"::STRING)) = 'administrative'
    AND pf."osm_id" IS NOT NULL
    AND pf."geometry" IS NOT NULL
),
admin_polygons AS (
  SELECT "osm_id", "geometry"
  FROM (
    SELECT ac.*,
           ROW_NUMBER() OVER (PARTITION BY ac."osm_id" ORDER BY ac."osm_timestamp" DESC NULLS LAST, ac."osm_id" ASC) AS rn
    FROM admin_candidates ac
  ) WHERE rn = 1
),
polygons_geog AS (
  SELECT
    "osm_id",
    ST_GEOGRAPHYFROMWKB("geometry") AS "geom"
  FROM admin_polygons
),
amenity_nodes AS (
  SELECT DISTINCT
    pn."id" AS "node_id",
    pn."latitude" AS "latitude",
    pn."longitude" AS "longitude"
  FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_NODES AS pn,
       LATERAL FLATTEN(INPUT => pn."all_tags") tag
  WHERE tag.value:"key"::STRING = 'amenity'
    AND pn."latitude" IS NOT NULL
    AND pn."longitude" IS NOT NULL
),
nodes_geog AS (
  SELECT
    "node_id",
    ST_MAKEPOINT("longitude", "latitude") AS "pt"
  FROM amenity_nodes
),
counts_per_polygon AS (
  SELECT
    p."osm_id" AS "osm_id",
    COALESCE(COUNT(DISTINCT n."node_id"), 0) AS "cnt"
  FROM polygons_geog p
  LEFT JOIN nodes_geog n
    ON ST_DWITHIN(p."geom", n."pt", 0.0)
  GROUP BY p."osm_id"
),
median_val AS (
  SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "cnt") AS "median_cnt"
  FROM counts_per_polygon
),
distances AS (
  SELECT
    c."osm_id",
    c."cnt",
    ABS(c."cnt" - m."median_cnt") AS "dist"
  FROM counts_per_polygon c
  CROSS JOIN median_val m
)
SELECT "osm_id"
FROM distances
ORDER BY "dist" ASC NULLS LAST, "osm_id" ASC
LIMIT 1;