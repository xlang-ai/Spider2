SELECT t1.*
  FROM 
  (SELECT Trips.trip_id TripId,
               Trips.duration_sec TripDuration,
               Trips.start_date TripStartDate,
               Trips.start_station_name TripStartStation,
               Trips.member_gender Gender,
               Regions.name RegionName
          FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` Trips
         INNER JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` StationInfo
            ON CAST(Trips.start_station_id AS STRING) = CAST(StationInfo.station_id AS STRING)
         INNER JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` Regions
            ON StationInfo.region_id = Regions.region_id
         WHERE (EXTRACT(YEAR from Trips.start_date)) BETWEEN 2014 AND 2017
           ) 
           t1
 RIGHT JOIN (SELECT MAX(start_date) TripStartDate,
                   Regions.name RegionName
              FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` StationInfo
             INNER JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` Trips
                ON CAST(StationInfo.station_id AS STRING) = CAST(Trips.start_station_id AS STRING)
             INNER JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` Regions
                ON Regions.region_id = StationInfo.region_id
                 WHERE (EXTRACT(YEAR from Trips.start_date) BETWEEN 2014 AND 2017
           AND Regions.name IS NOT NULL)
             GROUP BY RegionName) 
             t2
    ON t1.RegionName = t2.RegionName AND t1.TripStartDate = t2.TripStartDate