WITH bounding_area AS (
  SELECT geometry 
  FROM `bigquery-public-data.geo_openstreetmap.planet_features`
  WHERE feature_type = "multipolygons"
    AND ('wikidata', 'Q35') IN (
      SELECT (key, value) 
      FROM unnest(all_tags)
    )
),

highway_info AS (
  SELECT 
    SUM(ST_LENGTH(planet_features.geometry)) AS highway_length,
    format("%'d", CAST(SUM(ST_LENGTH(planet_features.geometry)) AS INT64)) AS highway_length_formatted,
    count(*) AS highway_count,
    (
      SELECT value 
      FROM unnest(all_tags) 
      WHERE key = 'highway'
    ) AS highway_type  -- Extract value of "highway" tag
  FROM 
    `bigquery-public-data.geo_openstreetmap.planet_features` planet_features, 
    bounding_area
  WHERE 
    feature_type = 'lines'
    AND 'highway' IN (
      SELECT key 
      FROM UNNEST(all_tags)
    ) -- Select highways
    AND ST_DWithin(bounding_area.geometry, planet_features.geometry, 0)  -- Filter only features within bounding_area
  GROUP BY 
    highway_type
)

SELECT 
  highway_type
FROM
  highway_info
ORDER BY 
  highway_length DESC
LIMIT 5
