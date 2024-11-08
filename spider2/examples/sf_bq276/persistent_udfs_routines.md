# BigQuery UDF Definitions

## `nautical_miles_conversion`

### Description
Converts nautical miles to statute miles by multiplying the input nautical miles by a fixed conversion factor. This function is commonly used in geographic analysis to convert marine-based distances into land-based measurements, which are more widely used in logistics and mapping.

### SQL Definition
```sql
CREATE FUNCTION `bigquery-public-data`.persistent_udfs.nautical_miles_conversion(input_nautical_miles FLOAT64)
AS (
  input_nautical_miles * 1.15078
);
```

### Example Usage
Convert the shipping distance between ports from nautical miles to statute miles for use in a logistics dashboard:
```sql
SELECT 
  port_name,
  `bigquery-public-data.persistent_udfs.nautical_miles_conversion`(distance_nautical_miles) AS distance_statute_miles
FROM 
  shipping_routes;
```

## `azimuth_to_geog_point`

### Description
Calculates a geographic point based on input latitude and longitude, an azimuth, and a distance. This function is particularly useful for spatial analyses that require generating new locations based on directional and distance parameters from a given point.

### Mathematical Operation
Employs trigonometric calculations to determine new geographic coordinates, accounting for Earth's curvature. The function adjusts direction (azimuth) and distance from degrees and nautical miles to radians and kilometers respectively.

### SQL Definition
```sql
CREATE FUNCTION `bigquery-public-data`.persistent_udfs.azimuth_to_geog_point(input_lat FLOAT64, input_lon FLOAT64, azimuth FLOAT64, distance FLOAT64)
AS (
  ST_GeogPoint(
    57.2958*(input_lon*(3.14159/180)+(atan2(
      sin(azimuth * (3.14159/180)) * sin(distance * 1.61/6378.1) * cos(input_lat* (3.14159/180)),
      cos(distance * 1.61/6378.1) - sin(input_lat * (3.14159/180)) * sin(57.2958*(asin(
        sin(input_lat * (3.14159/180)) * cos(distance * 1.61/6378.1) + cos(input_lat * (3.14159/180)) * sin(distance * 1.61/6378.1) * cos(azimuth*(3.14159/180)))
      )))
    )),
    57.2958*(asin(
      sin(input_lat * (3.14159/180)) * cos(distance * 1.61/6378.1) + cos(input_lat * (3.14159/180)) * sin(distance * 1.61/6378.1) * cos(azimuth*(3.14159/180))
    ))
  )
);
```

### Example Usage
Generate waypoints for a scenic route that requires specific directional travel from a starting location for a hiking app:
```sql
SELECT 
  trail_start_name,
  ARRAY_AGG(
    ST_AsText(
      `bigquery-public-data.persistent_udfs.azimuth_to_geog_point`(start_lat, start_lon, step_azimuth, step_distance)
    )
  ) AS waypoints
FROM 
  hiking_trails
CROSS JOIN 
  UNNEST(trail_steps) AS t
GROUP BY 
  trail_start_name;
```
