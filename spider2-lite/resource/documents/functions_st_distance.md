Categories: Geospatial functions


## ST_DISTANCE

Returns the minimum geodesic distance between two GEOGRAPHY or the minimum Euclidean distance between two GEOMETRY objects.

## Syntax

ST_DISTANCE( <geography_or_geometry_expression_1> , <geography_or_geometry_expression_2> )


## Arguments


geography_or_geometry_expression_1The argument must be of type GEOGRAPHY or GEOMETRY.

geography_or_geometry_expression_2The argument must be of type GEOGRAPHY or GEOMETRY.


## Returns

Returns a REAL value, which represents the distance:

For GEOGRAPHY input values, the distance is in meters.
For GEOMETRY input values, the distance is computed with the same units used to define the input coordinates.


## Usage notes


Returns NULL if one or more input points are NULL.

For GEOMETRY objects, the function reports an error if the two input GEOMETRY objects have different SRIDs.


## Examples


## GEOGRAPHY examples

This shows the distance in meters between two points 1 degree apart along the equator (approximately 111 kilometers or 69 miles).

WITH d AS
    ( ST_DISTANCE(ST_MAKEPOINT(0, 0), ST_MAKEPOINT(1, 0)) ) SELECT d / 1000 AS kilometers, d / 1609 AS miles;
+---------------+--------------+
|    KILOMETERS |        MILES |
|---------------+--------------|
| 111.195101177 | 69.108204585 |
+---------------+--------------+


This shows use of the ST_DISTANCE function with NULL values:

SELECT ST_DISTANCE(ST_MAKEPOINT(0, 0), ST_MAKEPOINT(NULL, NULL));
+-----------------------------------------------------------+
| ST_DISTANCE(ST_MAKEPOINT(0, 0), ST_MAKEPOINT(NULL, NULL)) |
|-----------------------------------------------------------|
|                                                      NULL |
+-----------------------------------------------------------+



## GEOMETRY examples

The following example compares the distance calculated for GEOGRAPHY and GEOMETRY input objects.

SELECT ST_DISTANCE(TO_GEOMETRY('POINT(0 0)'), TO_GEOMETRY('POINT(1 1)')) AS geometry_distance,
       ST_DISTANCE(TO_GEOGRAPHY('POINT(0 0)'), TO_GEOGRAPHY('POINT(1 1)')) AS geography_distance;

+-------------------+--------------------+
| GEOMETRY_DISTANCE | GEOGRAPHY_DISTANCE |
|-------------------+--------------------|
|       1.414213562 |   157249.628092508 |
+-------------------+--------------------+