WITH philadelphia AS (
    SELECT 
        * 
    FROM 
        GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_US_CENSUS_PLACES.PLACES_PENNSYLVANIA
    WHERE 
        "place_name" = 'Philadelphia'
),
amenities AS (
    SELECT 
        features.*, 
        tags.value:"value" AS amenity
    FROM 
        GEO_OPENSTREETMAP_CENSUS_PLACES.GEO_OPENSTREETMAP.PLANET_FEATURES_POINTS AS features
    CROSS JOIN philadelphia
    -- Use FLATTEN on "all_tags" to get the tags and filter by "key"
    , LATERAL FLATTEN(input => features."all_tags") AS tags
    WHERE 
        ST_CONTAINS(ST_GEOGFROMWKB(philadelphia."place_geom"), ST_GEOGFROMWKB(features."geometry"))
    AND 
        tags.value:"key" = 'amenity' 
    AND 
        tags.value:"value" IN ('library', 'place_of_worship', 'community_centre')
),
joiin AS (
    SELECT 
        a1.*, 
        a2."osm_id" AS nearest_osm_id, 
        ST_DISTANCE(ST_GEOGFROMWKB(a1."geometry"), ST_GEOGFROMWKB(a2."geometry")) AS distance, 
        ROW_NUMBER() OVER (PARTITION BY a1."osm_id" ORDER BY ST_DISTANCE(ST_GEOGFROMWKB(a1."geometry"), ST_GEOGFROMWKB(a2."geometry"))) AS row_num
    FROM amenities a1
    CROSS JOIN amenities a2
    WHERE a1."osm_id" < a2."osm_id"
    ORDER BY a1."osm_id", distance
) 
SELECT distance
FROM joiin  
WHERE row_num = 1
ORDER BY distance ASC
LIMIT 1;
