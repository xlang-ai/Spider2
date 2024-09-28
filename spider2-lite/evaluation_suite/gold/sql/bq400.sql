WITH SelectedStops AS (
  SELECT 
      stop_id,
      stop_name
  FROM 
      `bigquery-public-data.san_francisco_transit_muni.stops`
  WHERE 
      stop_name IN ('Clay St & Drumm St', 'Sacramento St & Davis St')
),
FilteredStopTimes AS (
  SELECT 
      st.trip_id, 
      st.stop_id, 
      st.arrival_time, 
      st.departure_time, 
      st.stop_sequence, 
      ss.stop_name
  FROM 
      `bigquery-public-data.san_francisco_transit_muni.stop_times` st
  JOIN 
      SelectedStops ss ON CAST(st.stop_id AS STRING) = ss.stop_id
)
SELECT
    t.trip_headsign,
    MIN(st1.departure_time) AS start_time,
    MAX(st2.arrival_time) AS end_time
FROM 
    `bigquery-public-data.san_francisco_transit_muni.trips` t
JOIN FilteredStopTimes st1 ON t.trip_id = CAST(st1.trip_id AS STRING) AND st1.stop_name = 'Clay St & Drumm St'
JOIN FilteredStopTimes st2 ON t.trip_id = CAST(st2.trip_id AS STRING) AND st2.stop_name = 'Sacramento St & Davis St'
WHERE 
    st1.stop_sequence < st2.stop_sequence
GROUP BY 
    t.trip_headsign;