WITH philly_amenities AS (
    SELECT
        "p"."osm_id",
        TO_GEOGRAPHY("p"."geometry") AS "geo"
    FROM
        "GEO_OPENSTREETMAP_CENSUS_PLACES"."GEO_US_CENSUS_PLACES"."PLACES_PENNSYLVANIA" AS "pa"
    JOIN
        "GEO_OPENSTREETMAP_CENSUS_PLACES"."GEO_OPENSTREETMAP"."PLANET_FEATURES_POINTS" AS "p"
        ON ST_CONTAINS(TO_GEOGRAPHY("pa"."place_geom"), TO_GEOGRAPHY("p"."geometry"))
    , TABLE(FLATTEN("p"."all_tags")) AS "t"
    WHERE
        "pa"."place_name" = 'Philadelphia'
        AND "t"."VALUE":"key"::STRING = 'amenity'
        AND "t"."VALUE":"value"::STRING IN ('library', 'place_of_worship', 'community_centre')
)
SELECT
    MIN(ST_DISTANCE("a1"."geo", "a2"."geo"))
FROM
    philly_amenities AS "a1"
CROSS JOIN
    philly_amenities AS "a2"
WHERE
    "a1"."osm_id" < "a2"."osm_id"