

# Requirements

The following shows the SQL operations you must perform. Please implement the corresponding functionality in your SQL code according to the description.

## `nautical_miles_conversion`

### Description
Converts nautical miles to statute miles by multiplying the input nautical miles by a fixed conversion factor. This operation is commonly used in geographic analysis to convert marine-based distances into land-based measurements, which are more widely used in logistics and mapping.

### SQL Definition
```sql
nautical_miles_conversion(input_nautical_miles FLOAT64)
AS (
  input_nautical_miles * 1.15078
);
```

## `azimuth_to_geog_point`

### Description
Calculates a geographic point based on input latitude and longitude, an azimuth, and a distance. This operation is particularly useful for spatial analyses that require generating new locations based on directional and distance parameters from a given point.

### Mathematical Operation
Employs trigonometric calculations to determine new geographic coordinates, accounting for Earth's curvature. The operation adjusts direction (azimuth) and distance from degrees and nautical miles to radians and kilometers respectively.

### SQL Definition
```sql
SELECT
  ST_MAKEPOINT(
    57.2958 * (
      input_lon * (3.14159 / 180) + ATAN2(
        SIN(azimuth * (3.14159 / 180)) * SIN(distance * 1.61 / 6378.1) * COS(input_lat * (3.14159 / 180)),
        COS(distance * 1.61 / 6378.1) - SIN(input_lat * (3.14159 / 180)) * SIN(
          57.2958 * ASIN(
            SIN(input_lat * (3.14159 / 180)) * COS(distance * 1.61 / 6378.1) +
            COS(input_lat * (3.14159 / 180)) * SIN(distance * 1.61 / 6378.1) * COS(azimuth * (3.14159 / 180))
          )
        )
      )
    ),
    57.2958 * ASIN(
      SIN(input_lat * (3.14159 / 180)) * COS(distance * 1.61 / 6378.1) +
      COS(input_lat * (3.14159 / 180)) * SIN(distance * 1.61 / 6378.1) * COS(azimuth * (3.14159 / 180))
    )
  ) AS destination_point
FROM
  your_table;
```




# Functions

You should use the following built-in Snowflake functions.


## ST_WITHIN

Returns true if the first geospatial object is fully contained by the second geospatial object. In other words:

The first GEOGRAPHY object g1 is fully contained by the second GEOGRAPHY object g2.
The first GEOMETRY object g1 is fully contained by the second GEOMETRY object g2.

Calling ST_WITHIN(g1, g2) is equivalent to calling ST_CONTAINS(g2, g1).
Although ST_COVEREDBY and ST_WITHIN might seem similar, the two functions have subtle differences. For details on the differences between “covered by” and “within”, see the Dimensionally Extended 9-Intersection Model (DE-9IM).

Note This function does not support using a GeometryCollection or FeatureCollection as input values.

Tip You can use the search optimization service to improve the performance of queries that call this function.
For details, see Search Optimization Service.

See also:ST_CONTAINS , ST_COVEREDBY


## Syntax

ST_WITHIN( <geography_expression_1> , <geography_expression_2> )

ST_WITHIN( <geometry_expression_1> , <geometry_expression_2> )


## Arguments


geography_expression_1A GEOGRAPHY object that is not a GeometryCollection or FeatureCollection.

geography_expression_2A GEOGRAPHY object that is not a GeometryCollection or FeatureCollection.

geometry_expression_1A GEOMETRY object that is not a GeometryCollection or FeatureCollection.

geometry_expression_2A GEOMETRY object that is not a GeometryCollection or FeatureCollection.


## Returns

BOOLEAN.

## Examples


## GEOGRAPHY examples

This shows a simple use of the ST_WITHIN function:

create table geospatial_table_01 (g1 GEOGRAPHY, g2 GEOGRAPHY);
insert into geospatial_table_01 (g1, g2) values 
    ('POLYGON((0 0, 3 0, 3 3, 0 3, 0 0))', 'POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))');

Copy SELECT ST_WITHIN(g1, g2) 
    FROM geospatial_table_01;
+-------------------+
| ST_WITHIN(G1, G2) |
|-------------------|
| False             |
+-------------------+




## ST_MAKELINE

Constructs a GEOGRAPHY or GEOMETRY object that represents a line connecting the points in the input objects.

See also:TO_GEOGRAPHY , TO_GEOMETRY


## Syntax

ST_MAKELINE( <geography_expression_1> , <geography_expression_2> )

ST_MAKELINE( <geometry_expression_1> , <geometry_expression_2> )


## Arguments


geography_expression_1A GEOGRAPHY object containing the points to connect. This object must be a Point, MultiPoint, or LineString.

geography_expression_2A GEOGRAPHY object containing the points to connect. This object must be a Point, MultiPoint, or LineString.

geometry_expression_1A GEOMETRY object containing the points to connect. This object must be a Point, MultiPoint, or LineString.

geometry_expression_2A GEOMETRY object containing the points to connect. This object must be a Point, MultiPoint, or LineString.


## Returns

The function returns a value of type GEOGRAPHY or GEOMETRY. The value is a LineString that connects all of the points specified by the input GEOGRAPHY or GEOMETRY objects.

## Usage notes


If an input GEOGRAPHY object contains multiple points, ST_MAKELINE connects all of the points specified in the object.
ST_MAKELINE connects the points in the order in which they are specified in the input.

For GEOMETRY objects, the function reports an error if the two input GEOMETRY objects have different SRIDs.

For GEOMETRY objects, the returned GEOMETRY object has the same SRID as the input.


## Examples


## GEOGRAPHY examples

The examples in this section display output in WKT format:

alter session set GEOGRAPHY_OUTPUT_FORMAT='WKT';


The following example uses ST_MAKELINE to construct a LineString that connects two Points:

SELECT ST_MAKELINE(
                   TO_GEOGRAPHY('POINT(37.0 45.0)'),
                   TO_GEOGRAPHY('POINT(38.5 46.5)')
                  ) AS line_between_two_points;
+-----------------------------+
| LINE_BETWEEN_TWO_POINTS     |
|-----------------------------|
| LINESTRING(37 45,38.5 46.5) |
+-----------------------------+


The following example constructs a LineString that connects a Point with the points in a MultiPoint:

SELECT ST_MAKELINE(
                   TO_GEOGRAPHY('POINT(-122.306067 37.55412)'),
                   TO_GEOGRAPHY('MULTIPOINT((-122.32328 37.561801), (-122.325879 37.586852))')
                  ) AS line_between_point_and_multipoint;
+-----------------------------------------------------------------------------+
| LINE_BETWEEN_POINT_AND_MULTIPOINT                                           |
|-----------------------------------------------------------------------------|
| LINESTRING(-122.306067 37.55412,-122.32328 37.561801,-122.325879 37.586852) |
+-----------------------------------------------------------------------------+


As demonstrated by the output of the example, ST_MAKELINE connects the points in the order in which they are specified in the input.
The following example constructs a LineString that connects the points in a MultiPoint with another LineString:

SELECT ST_MAKELINE(
                   TO_GEOGRAPHY('MULTIPOINT((-122.32328 37.561801), (-122.325879 37.586852))'),
                   TO_GEOGRAPHY('LINESTRING(-122.306067 37.55412, -122.496691 37.495627)')
                  ) AS line_between_multipoint_and_linestring;
+---------------------------------------------------------------------------------------------------+
| LINE_BETWEEN_MULTIPOINT_AND_LINESTRING                                                            |
|---------------------------------------------------------------------------------------------------|
| LINESTRING(-122.32328 37.561801,-122.325879 37.586852,-122.306067 37.55412,-122.496691 37.495627) |
+---------------------------------------------------------------------------------------------------+



## GEOMETRY examples

The examples in this section display output in WKT format:

ALTER SESSION SET GEOMETRY_OUTPUT_FORMAT='WKT';


The first example constructs a line between two Points:

SELECT ST_MAKELINE(
  TO_GEOMETRY('POINT(1.0 2.0)'),
  TO_GEOMETRY('POINT(3.5 4.5)')) AS line_between_two_points;

+-------------------------+
| LINE_BETWEEN_TWO_POINTS |
|-------------------------|
| LINESTRING(1 2,3.5 4.5) |
+-------------------------+


The next example demonstrates creating a LineString that connects points in a MultiPoint with a Point

SELECT ST_MAKELINE(
  TO_GEOMETRY('POINT(1.0 2.0)'),
  TO_GEOMETRY('MULTIPOINT(3.5 4.5, 6.1 7.9)')) AS line_from_point_and_multipoint;

+---------------------------------+
| LINE_FROM_POINT_AND_MULTIPOINT  |
|---------------------------------|
| LINESTRING(1 2,3.5 4.5,6.1 7.9) |
+---------------------------------+


The following example constructs a LineString that connects the points in a MultiPoint with another LineString:

SELECT ST_MAKELINE(
  TO_GEOMETRY('LINESTRING(1.0 2.0, 10.1 5.5)'),
  TO_GEOMETRY('MULTIPOINT(3.5 4.5, 6.1 7.9)')) AS line_from_linestring_and_multipoint;

+------------------------------------------+
| LINE_FROM_LINESTRING_AND_MULTIPOINT      |
|------------------------------------------|
| LINESTRING(1 2,10.1 5.5,3.5 4.5,6.1 7.9) |
+------------------------------------------+







## ST_MAKEPOLYGON , ST_POLYGON

Constructs a GEOGRAPHY or GEOMETRY object that represents a Polygon without holes. The function uses the specified LineString as the outer loop.
This function corrects the orientation of the loop to prevent the creation of Polygons that span more than half of the globe. In contrast, ST_MAKEPOLYGONORIENTED does not attempt to correct the orientation of the loop.

See also:TO_GEOGRAPHY , TO_GEOMETRY , ST_MAKEPOLYGONORIENTED


## Syntax

ST_MAKEPOLYGON( <geography_or_geometry_expression> )


## Arguments


geography_or_geometry_expressionA GEOGRAPHY or GEOMETRY object that represents a LineString in which the last point is the same as the first (i.e. a loop).


## Returns

The function returns a value of type GEOGRAPHY or GEOMETRY.

## Usage notes


The lines of the Polygon must form a loop. In other words, the last Point in the sequence of Points defining the LineString must be the same Point as the first Point in the sequence.
ST_POLYGON is an alias for ST_MAKEPOLYGON.

For GEOMETRY objects, the returned GEOMETRY object has the same SRID as the input.


## Examples


## GEOGRAPHY examples

This shows a simple use of the ST_MAKEPOLYGON function. The sequence of points below defines a geodesic rectangular area 1 degree wide and 2 degrees high, with the lower left corner of the polygon starting at the equator (latitude) and Greenwich (longitude). The last point in the sequence is the same as the first point,
which completes the loop.

SELECT ST_MAKEPOLYGON(
   TO_GEOGRAPHY('LINESTRING(0.0 0.0, 1.0 0.0, 1.0 2.0, 0.0 2.0, 0.0 0.0)')
   ) AS polygon1;
+--------------------------------+
| POLYGON1                       |
|--------------------------------|
| POLYGON((0 0,1 0,1 2,0 2,0 0)) |
+--------------------------------+



## GEOMETRY examples

This shows a simple use of the ST_MAKEPOLYGON function.

SELECT ST_MAKEPOLYGON(
  TO_GEOMETRY('LINESTRING(0.0 0.0, 1.0 0.0, 1.0 2.0, 0.0 2.0, 0.0 0.0)')
  ) AS polygon;

+--------------------------------+
| POLYGON                        |
|--------------------------------|
| POLYGON((0 0,1 0,1 2,0 2,0 0)) |
+--------------------------------+