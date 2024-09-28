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
       SELECT DISTINCT
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
),

average_crime_count AS (
   SELECT
       AVG(crime_count) AS avg_crime_count
   FROM
       neighborhood_crime_counts
),

neighborhood_distance_from_avg AS (
   SELECT
       ncc.neighborhood,
       ncc.crime_count,
       ABS(ncc.crime_count - avg.avg_crime_count) AS distance_from_avg
   FROM
       neighborhood_crime_counts ncc
   CROSS JOIN
       average_crime_count avg
),

closest_neighborhoods AS (
   SELECT
       neighborhood,
       crime_count
   FROM
       neighborhood_distance_from_avg
   WHERE
       distance_from_avg = (
           SELECT MIN(distance_from_avg)
           FROM neighborhood_distance_from_avg
       )
)

SELECT
   sn.neighborhood
FROM
   station_neighborhoods sn
JOIN
   closest_neighborhoods cn
ON
   sn.neighborhood = cn.neighborhood
GROUP BY
   sn.neighborhood
ORDER BY
   COUNT(sn.station_id) DESC
LIMIT 1;