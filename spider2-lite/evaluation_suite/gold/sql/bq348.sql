WITH singapore AS (
  SELECT 
      ST_MAKEPOLYGON(ST_MAKELINE(
    [ST_GEOGPOINT(31.1798246, 18.4519921),ST_GEOGPOINT(54.3798246, 18.4519921),
     ST_GEOGPOINT(54.3798246, 33.6519921),ST_GEOGPOINT(31.1798246, 33.6519921)
    ]
  )) AS boundingbox
),
historical_data AS (
  SELECT 
      hist.username, 
      hist.id
  FROM 
      `spider2-public-data.geo_openstreetmap.history_nodes` AS hist
  INNER JOIN UNNEST(all_tags) AS tags
  INNER JOIN singapore ON ST_INTERSECTS(singapore.boundingbox, hist.geometry)
  WHERE 
      tags.key = 'amenity'
    AND tags.value IN ('hospital', 'clinic', 'doctors')
    AND hist.id NOT IN (
      SELECT 
          nodes.id
      FROM 
          `spider2-public-data.geo_openstreetmap.planet_nodes` AS nodes
      INNER JOIN UNNEST(all_tags) AS tags
      INNER JOIN singapore ON ST_INTERSECTS(singapore.boundingbox, nodes.geometry)
      WHERE 
          tags.key = 'amenity'
        AND tags.value IN ('hospital', 'clinic', 'doctors')
    )
)
SELECT 
    username
FROM 
    historical_data
GROUP BY 
    username
ORDER BY 
    COUNT(*) DESC
LIMIT 3;