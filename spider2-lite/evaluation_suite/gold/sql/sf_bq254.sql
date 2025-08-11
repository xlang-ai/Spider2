WITH bounding_area AS (
    SELECT "geometry" AS geometry
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES,
    LATERAL FLATTEN(INPUT => "all_tags") AS tag
    WHERE "feature_type" = 'multipolygons'
      AND tag.value:"key" = 'wikidata'
      AND tag.value:"value" = 'Q191'
),
bounding_area_features AS (
    SELECT 
        planet_features."osm_id", 
        planet_features."feature_type", 
        planet_features."geometry", 
        planet_features."all_tags"
    FROM GEO_OPENSTREETMAP.GEO_OPENSTREETMAP.PLANET_FEATURES AS planet_features,
         bounding_area
    WHERE ST_DWITHIN(
        ST_GEOGFROMWKB(planet_features."geometry"), 
        ST_GEOGFROMWKB(bounding_area.geometry), 
        0.0
    )
),
osm_id_with_wikidata AS (
    SELECT DISTINCT
        baf."osm_id"
    FROM bounding_area_features AS baf,
         LATERAL FLATTEN(INPUT => baf."all_tags") AS tag
    WHERE tag.value:"key" = 'wikidata'
),

polygons_wo_wikidata AS (
    SELECT 
        baf."osm_id",
        tag.value:"value" as name,
        baf."geometry" as geometry
    FROM bounding_area_features AS baf
    LEFT JOIN osm_id_with_wikidata AS wd
      ON baf."osm_id" = wd."osm_id",
    LATERAL FLATTEN(INPUT => "all_tags") AS tag
    WHERE wd."osm_id" IS NULL
    AND baf."osm_id" IS NOT NULL
    AND baf."feature_type" = 'multipolygons'
    AND tag.value:"key" = 'name'
)

SELECT 
    TRIM(pww.name) as name
FROM bounding_area_features AS baf
JOIN polygons_wo_wikidata AS pww
    ON ST_DWITHIN(
        ST_GEOGFROMWKB(baf."geometry"), 
        ST_GEOGFROMWKB(pww.geometry), 
        0.0
    )
LEFT JOIN osm_id_with_wikidata AS wd
    ON baf."osm_id" = wd."osm_id"
WHERE wd."osm_id" IS NOT NULL
  AND baf."feature_type" = 'points'
GROUP BY pww.name
ORDER BY COUNT(baf."osm_id") DESC
LIMIT 2



