WITH station_neighborhoods AS (
   SELECT
       bs.station_id,
       bs.name AS station_name,
       nb.neighborhood
   FROM `bigquery-public-data.san_francisco.bikeshare_stations` bs
   JOIN
       bigquery-public-data.san_francisco_neighborhoods.boundaries nb
   ON 
       ST_Intersects(ST_GeogPoint(bs.longitude, bs.latitude), nb.neighborhood_geom)
),

neighborhood_crime_counts AS (
   SELECT
       neighborhood,
       COUNT(*) AS crime_count
   FROM (
       SELECT
           n.neighborhood
       FROM
           bigquery-public-data.san_francisco.sfpd_incidents i
       JOIN
           bigquery-public-data.san_francisco_neighborhoods.boundaries n
       ON
           ST_Intersects(ST_GeogPoint(i.longitude, i.latitude), n.neighborhood_geom)
   ) AS incident_neighborhoods
   GROUP BY
       neighborhood
)

SELECT
  sn.neighborhood,
  COUNT(station_name) AS station_number,
  ANY_VALUE(ncc.crime_count) AS crime_number
FROM
  station_neighborhoods sn
JOIN
  neighborhood_crime_counts ncc
ON
  sn.neighborhood = ncc.neighborhood
GROUP BY sn.neighborhood
ORDER BY
  crime_number ASC

