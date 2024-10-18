WITH bounding_area AS (
  SELECT geometry
  FROM `spider2-public-data.geo_openstreetmap.planet_features`
  WHERE feature_type = "multipolygons"
    AND ('wikidata', 'Q35') IN (
      SELECT (key, value)
      FROM unnest(all_tags)
    )
),

INFO AS (
  SELECT 
    COUNT(*) AS stops_count,
    (
      SELECT value 
      FROM unnest(all_tags) 
      WHERE key = 'network'
    ) AS bus_network
  FROM 
    `spider2-public-data.geo_openstreetmap.planet_features` planet_features,
    bounding_area
  WHERE 
    feature_type = 'points'
    AND ('highway', 'bus_stop') IN (
      SELECT (key, value)
      FROM UNNEST(all_tags)
    ) -- Select bus stops
    AND ST_DWithin(bounding_area.geometry, planet_features.geometry, 0)  -- Filter only features within bounding_area
  GROUP BY 
    bus_network
  ORDER BY 
    stops_count DESC 
)

SELECT stops_count
FROM INFO
ORDER BY 
  stops_count DESC 
LIMIT 1