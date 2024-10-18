WITH bounding_area AS (
    SELECT geometry FROM `spider2-public-data.geo_openstreetmap.planet_features`
    WHERE feature_type="multipolygons"
    AND ('wikidata', 'Q191') IN (SELECT (key, value) FROM unnest(all_tags))
),
bounding_area_features AS (
    SELECT planet_features.osm_id, planet_features.feature_type, planet_features.geometry, planet_features.all_tags FROM `spider2-public-data.geo_openstreetmap.planet_features` as planet_features, bounding_area
    WHERE ST_DWithin(bounding_area.geometry, planet_features.geometry, 0)
),
polygons_wo_wikidata as (
    SELECT planet_multipolygons.osm_id as id, (SELECT value FROM unnest(planet_multipolygons.all_tags) where key = 'name') as name, planet_multipolygons.geometry as geometry
    FROM bounding_area_features as planet_multipolygons,
      bounding_area
    WHERE feature_type = 'multipolygons'
    AND osm_id IS NOT NULL
    AND 'wikidata' NOT IN (SELECT key FROM UNNEST(all_tags))
    AND ST_DWithin(bounding_area.geometry, planet_multipolygons.geometry, 0)
)
SELECT polygons_wo_wikidata.name as name
FROM bounding_area_features as baf, polygons_wo_wikidata
WHERE 'wikidata' IN (SELECT key FROM UNNEST(all_tags)) AND polygons_wo_wikidata.name IS NOT NULL
AND baf.feature_type = "points"
AND ST_DWithin(baf.geometry, polygons_wo_wikidata.geometry, 0)
GROUP BY polygons_wo_wikidata.id, polygons_wo_wikidata.name
ORDER BY COUNT(baf.osm_id) DESC
LIMIT 2;