WITH incident_stats AS (
  SELECT 
    COUNT(descript) AS total_pub_intox
  FROM 
    `bigquery-public-data.austin_incidents.incidents_2016` 
  WHERE 
    descript = 'PUBLIC INTOXICATION' 
  GROUP BY 
    date
),
average_and_stddev AS (
  SELECT 
    AVG(total_pub_intox) AS avg, 
    STDDEV(total_pub_intox) AS stddev 
  FROM 
    incident_stats
),
daily_z_scores AS (
  SELECT 
    date, 
    COUNT(descript) AS total_pub_intox, 
    ROUND((COUNT(descript) - a.avg) / a.stddev, 2) AS z_score
  FROM 
    `bigquery-public-data.austin_incidents.incidents_2016`,
    (SELECT avg, stddev FROM average_and_stddev) AS a
  WHERE 
    descript = 'PUBLIC INTOXICATION'
  GROUP BY 
    date, avg, stddev
)

SELECT 
  date
FROM 
  daily_z_scores
ORDER BY 
  z_score DESC
LIMIT 1
OFFSET 1