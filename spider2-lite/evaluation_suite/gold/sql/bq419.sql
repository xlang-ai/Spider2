WITH s80 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1980` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),
s81 as
(SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1981` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),
s82 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1982` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s83 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1983` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s84 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1984` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s85 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1985` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s86 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1986` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s87 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1987` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s88 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1988` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s89 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1989` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s90 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1990` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s91 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1991` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),
s92 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1992` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s93 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1993` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s94 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1994` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000),

s95 as
  (SELECT state, COUNT(event_id) as num_events
  FROM `bigquery-public-data.noaa_historic_severe_storms.storms_1995` 
  GROUP BY state 
  ORDER BY num_events DESC
  LIMIT 1000)

SELECT s80.state, 
s80.num_events + s81.num_events +  s82.num_events +  s83.num_events +  s84.num_events +  s85.num_events +  s86.num_events +  s87.num_events + s88.num_events +  s89.num_events +  s90.num_events + s91.num_events + s92.num_events + s93.num_events + s94.num_events + s95.num_events as total_events 
FROM s80 FULL JOIN s81 ON s80.state = s81.state
FULL JOIN s82 ON s82.state = s81.state
FULL JOIN s83 ON s83.state = s81.state
FULL JOIN s84 ON s84.state = s81.state
FULL JOIN s85 ON s85.state = s81.state
FULL JOIN s86 ON s86.state = s81.state
FULL JOIN s87 ON s87.state = s81.state
FULL JOIN s88 ON s88.state = s81.state
FULL JOIN s89 ON s89.state = s81.state
FULL JOIN s90 ON s90.state = s81.state
FULL JOIN s91 ON s91.state = s81.state 
FULL JOIN s92 ON s92.state = s81.state
FULL JOIN s93 ON s93.state = s81.state
FULL JOIN s94 ON s94.state = s81.state
FULL JOIN s95 ON s95.state = s81.state

ORDER BY total_events DESC
LIMIT 5;