Categories: Geospatial functions


## ST_DWITHIN

Returns TRUE if the minimum geodesic distance between two points (two GEOGRAPHY objects) is within the specified distance. Otherwise, returns FALSE.
If the parameters are GEOGRAPHY values that are not points (e.g. lines or polygons), this returns TRUE or FALSE based on the minimum geodesic distance between the two closest points of the two values.

Tip You can use the search optimization service to improve the performance of queries that call this function.
For details, see Search Optimization Service.

## Syntax

ST_DWITHIN( <geography_expression_1> , <geography_expression_2> , <distance_in_meters> )


## Arguments


geography_expression_1The argument must be an expression of type GEOGRAPHY.

geography_expression_2The argument must be an expression of type GEOGRAPHY.

distance_in_metersThe argument must be an expression of type REAL. The distance is in meters.


## Returns

Returns a BOOLEAN.

## Usage notes


Returns NULL if any input is NULL.


## Examples

This returns TRUE because the distance in meters between two points 1 degree apart along the equator is less than 150,000 meters:

SELECT ST_DWITHIN (ST_MAKEPOINT(0, 0), ST_MAKEPOINT(1, 0), 150000);
+-------------------------------------------------------------+
| ST_DWITHIN (ST_MAKEPOINT(0, 0), ST_MAKEPOINT(1, 0), 150000) |
|-------------------------------------------------------------|
| True                                                        |
+-------------------------------------------------------------+