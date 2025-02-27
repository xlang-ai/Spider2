WITH t2 AS
(
SELECT 
    t.*,
    t.pickup_location_id as pickup_zone_id,
    tz.borough as pickup_borough
FROM
(
SELECT *,
    TIMESTAMP_DIFF(dropoff_datetime,pickup_datetime,SECOND) as time_duration_in_secs,
    (CASE WHEN total_amount=0 THEN 0
    ELSE (tip_amount*100/total_amount) END) as tip_rate
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`
) t
INNER JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` tz
ON t.pickup_location_id = tz.zone_id
WHERE 
    pickup_datetime BETWEEN '2016-01-01' AND '2016-01-07' 
    AND dropoff_datetime BETWEEN '2016-01-01' AND '2016-01-07'
    AND TIMESTAMP_DIFF(dropoff_datetime,pickup_datetime,SECOND) > 0
    AND passenger_count > 0
    AND trip_distance >= 0 
    AND tip_amount >= 0 
    AND tolls_amount >= 0 
    AND mta_tax >= 0 
    AND fare_amount >= 0
    AND total_amount >= 0
),
t3 AS
(SELECT 
pickup_borough,
(CASE 
    WHEN tip_rate = 0 THEN 'no tip'
    WHEN tip_rate <= 5 THEN 'Less than 5%'
    WHEN tip_rate <= 10 THEN '5% to 10%'
    WHEN tip_rate <= 15 THEN '10% to 15%'
    WHEN tip_rate <= 20 THEN '15% to 20%'
    WHEN tip_rate <= 25 THEN '20% to 25%'
    ELSE 'More than 25%' END)as tip_category,
COUNT(*) as no_of_trips
FROM t2
GROUP BY 1,2
ORDER BY pickup_borough ASC),
INFO AS (
SELECT pickup_borough
     , tip_category
     , Sum(no_of_trips) as no_of_trips,
     (CASE 
          WHEN pickup_borough is null THEN (select sum(no_of_trips)
          FROM t3)
          
          WHEN pickup_borough is not null and tip_category is null THEN (select sum(no_of_trips)
          FROM t3)
          
          WHEN pickup_borough is not null and tip_category is not null THEN (select sum(no_of_trips)
          FROM t3
          WHERE pickup_borough = m.pickup_borough)
          END) as parent_sum,
       (
          Sum(no_of_trips)
            /
          (
            CASE 
          WHEN pickup_borough is null THEN (select sum(no_of_trips)
          FROM t3)
          
          WHEN pickup_borough is not null and tip_category is null THEN (select sum(no_of_trips)
          FROM t3)
          
          WHEN pickup_borough is not null and tip_category is not null THEN (select sum(no_of_trips)
          FROM t3
          WHERE pickup_borough = m.pickup_borough)
          END
          )
        ) as percentage
FROM t3 m
GROUP BY ROLLUP(pickup_borough, tip_category)
order by 1, 2
)

SELECT 
    pickup_borough,
    (SUM(CASE WHEN tip_category = 'no tip' THEN no_of_trips ELSE 0 END) * 100.0 / SUM(no_of_trips)) AS percentage_no_tip
FROM t3
GROUP BY pickup_borough
ORDER BY pickup_borough;