WITH zip_areas AS (
    SELECT
        geo.geo_id,
        geo.geo_name AS zip,
        states.related_geo_name AS state,
        countries.related_geo_name AS country,
        ST_AREA(TRY_TO_GEOGRAPHY(value)) AS area
    FROM US_ADDRESSES__POI.CYBERSYN.geography_index AS geo
    JOIN US_ADDRESSES__POI.CYBERSYN.geography_relationships AS states
        ON (geo.geo_id = states.geo_id AND states.related_level = 'State')
    JOIN US_ADDRESSES__POI.CYBERSYN.geography_relationships AS countries
        ON (geo.geo_id = countries.geo_id AND countries.related_level = 'Country')
    JOIN US_ADDRESSES__POI.CYBERSYN.geography_characteristics AS chars
        ON (geo.geo_id = chars.geo_id AND chars.relationship_type = 'coordinates_geojson')
    WHERE geo.level = 'CensusZipCodeTabulationArea'
),

zip_area_ranks AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY country, state ORDER BY area DESC, geo_id) AS zip_area_rank
    FROM zip_areas
)

SELECT addr.number, addr.street, addr.street_type
FROM US_ADDRESSES__POI.CYBERSYN.us_addresses AS addr
JOIN zip_area_ranks AS areas
    ON (addr.id_zip = areas.geo_id)
WHERE addr.state = 'FL' AND areas.country = 'United States' AND areas.zip_area_rank = 1
ORDER BY LATITUDE DESC
LIMIT 10;