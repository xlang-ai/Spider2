WITH bounding_area AS (
    SELECT 
        osm_id, 
        geometry,
        ST_Area(geometry) AS area
    FROM `spider2-public-data.geo_openstreetmap.planet_features`
    WHERE 
        feature_type = "multipolygons"
        AND ('boundary', 'administrative') IN (SELECT (key, value) FROM UNNEST(all_tags))
),

poi AS (
    SELECT 
        nodes.id AS poi_id,
        nodes.geometry AS poi_geometry,
        tags.value AS poitype
    FROM `spider2-public-data.geo_openstreetmap.planet_nodes` AS nodes
    JOIN UNNEST(nodes.all_tags) AS tags
    WHERE tags.key = 'amenity'
),

poi_counts AS (
    SELECT
        ba.osm_id,
        COUNT(poi.poi_id) AS total_pois
    FROM bounding_area ba
    JOIN poi
    ON ST_DWithin(ba.geometry, poi.poi_geometry, 0)
    GROUP BY ba.osm_id
),

median_value AS (
    SELECT
        APPROX_QUANTILES(total_pois, 2)[OFFSET(1)] AS median_pois
    FROM poi_counts
),

closest_to_median AS (
    SELECT
        osm_id,
        total_pois,
        ABS(total_pois - median_pois) AS diff_from_median
    FROM poi_counts, median_value
)

SELECT
    osm_id
FROM closest_to_median
ORDER BY diff_from_median
LIMIT 1;