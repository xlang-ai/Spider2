WITH bounding_area AS (
    SELECT geometry FROM `spider2-public-data.geo_openstreetmap.planet_features`
    WHERE feature_type="multipolygons"
    AND ('wikidata', 'Q1095') IN (SELECT (key, value) FROM unnest(all_tags))
),
relations_wo_wikidata as (
    SELECT planet_relations.id, (SELECT value FROM unnest(planet_relations.all_tags) where key = 'name') as name, m.id as member_id
    FROM `spider2-public-data.geo_openstreetmap.planet_relations` as planet_relations,
      planet_relations.members as m,
      bounding_area
    WHERE 'wikidata' NOT IN (SELECT key FROM UNNEST(all_tags))
    AND ST_DWithin(bounding_area.geometry, planet_relations.geometry, 0)
),
bounding_area_features AS (
    SELECT * FROM `spider2-public-data.geo_openstreetmap.planet_features` as planet_features, bounding_area
    WHERE ST_DWithin(bounding_area.geometry, planet_features.geometry, 0)
)
SELECT relations_wo_wikidata.name
FROM relations_wo_wikidata 
JOIN bounding_area_features as planet_features 
ON relations_wo_wikidata.member_id = planet_features.osm_id
WHERE 'wikidata' IN 
(SELECT key FROM UNNEST(all_tags)) 
AND relations_wo_wikidata.name IS NOT NULL
GROUP BY id, name
ORDER BY COUNT(planet_features.osm_id) DESC
LIMIT 1
;