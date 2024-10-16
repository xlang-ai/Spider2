WITH philadelphia AS (
    SELECT 
        * 
    FROM 
        `bigquery-public-data.geo_us_census_places.places_pennsylvania` 
    WHERE 
        place_name = 'Philadelphia'
),
amenities AS (
    SELECT *, 
           (
                SELECT 
                    tags.value 
                FROM 
                    UNNEST(all_tags) AS tags 
                WHERE 
                    tags.key = 'amenity'
           ) AS amenity
    FROM 
        `spider2-public-data.geo_openstreetmap.planet_features_points` AS features
    CROSS JOIN philadelphia
    WHERE ST_CONTAINS(philadelphia.place_geom, features.geometry)
    AND 
    (
        EXISTS (
            SELECT 1 
            FROM UNNEST(all_tags) AS tags 
            WHERE tags.key = 'amenity' 
            AND tags.value IN ('library', 'place_of_worship', 'community_centre')
        )
    )
),
joiin AS (
    SELECT 
        a1.*, 
        a2.osm_id AS nearest_osm_id, 
        ST_DISTANCE(a1.geometry, a2.geometry) AS distance, 
        ROW_NUMBER() OVER (PARTITION BY a1.osm_id ORDER BY ST_Distance(a1.geometry, a2.geometry)) AS row_num
    FROM amenities a1
    CROSS JOIN amenities a2
    WHERE a1.osm_id < a2.osm_id
    ORDER BY a1.osm_id, distance
) 
SELECT distance
FROM joiin  
WHERE row_num = 1
ORDER BY distance ASC
LIMIT 1;
