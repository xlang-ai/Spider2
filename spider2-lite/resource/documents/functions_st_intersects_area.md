Categories: Geospatial functions


## ST_INTERSECTS

Returns TRUE if the two GEOGRAPHY objects or the two GEOMETRY objects intersect (i.e. share any portion of space).

Note This function does not support using a GeometryCollection or FeatureCollection as input values.

Tip You can use the search optimization service to improve the performance of queries that call this function.
For details, see Search Optimization Service.

See also:ST_DISJOINT


## Syntax

ST_INTERSECTS( <geography_expression_1> , <geography_expression_2> )

ST_INTERSECTS( <geometry_expression_1> , <geometry_expression_2> )


## Arguments


geography_expression_1A GEOGRAPHY object.

geography_expression_2A GEOGRAPHY object.

geometry_expression_1A GEOMETRY object.

geometry_expression_2A GEOMETRY object.


## Returns

BOOLEAN.

## Usage notes


For GEOMETRY objects, the function reports an error if the two input GEOMETRY objects have different SRIDs.


## Examples


## GEOGRAPHY examples

This shows a simple use of the ST_INTERSECTS function:

SELECT ST_INTERSECTS(
    TO_GEOGRAPHY('POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))'),
    TO_GEOGRAPHY('POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))')
    );
+---------------------------------------------------------+
| ST_INTERSECTS(                                          |
|     TO_GEOGRAPHY('POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))'), |
|     TO_GEOGRAPHY('POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))')  |
|     )                                                   |
|---------------------------------------------------------|
| True                                                    |
+---------------------------------------------------------+



## GEOMETRY examples

This shows a simple use of the ST_INTERSECTS function:

SELECT ST_INTERSECTS(
  TO_GEOMETRY('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'),
  TO_GEOMETRY('POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))') );

+------------------------------------------------------+
| ST_INTERSECTS(                                       |
|   TO_GEOMETRY('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'), |
|   TO_GEOMETRY('POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))')  |
| )                                                    |
|------------------------------------------------------|
| True                                                 |
+------------------------------------------------------+




## ST_AREA

Returns the area of the Polygon(s) in a GEOGRAPHY or GEOMETRY object.

## Syntax

ST_AREA( <geography_or_geometry_expression> )


## Arguments


geography_or_geometry_expressionThe argument must be of type GEOGRAPHY or GEOMETRY.


## Returns

Returns a REAL value, which represents the area:

For GEOGRAPHY input values, the area is in square meters.
For GEOMETRY input values, the area is computed with the same units used to define the input coordinates.


## Usage notes


If geography_expression is not a Polygon, MultiPolygon, or GeometryCollection containing polygons, ST_AREA returns 0.
If geography_expression is a GeometryCollection, ST_AREA returns the sum of the areas of the polygons in the collection.


## Examples


## GEOGRAPHY examples

This uses the ST_AREA function with GEOGRAPHY objects to calculate the area of Earth’s surface 1 degree on each side with the bottom of the area on the equator:

SELECT ST_AREA(TO_GEOGRAPHY('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AS area;
+------------------+
|             AREA |
|------------------|
| 12364036567.0764 |
+------------------+



## GEOMETRY examples

The following example calls the ST_AREA function with GEOMETRY objects that represent a Point, LineString, and Polygon.

SELECT ST_AREA(g), ST_ASWKT(g) FROM (SELECT TO_GEOMETRY(column1) as g
  from values ('POINT(1 1)'),
              ('LINESTRING(0 0, 1 1)'),
              ('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'));

+------------+--------------------------------+
| ST_AREA(G) | ST_ASWKT(G)                    |
|------------+--------------------------------|
|          0 | POINT(1 1)                     |
|          0 | LINESTRING(0 0,1 1)            |
|          1 | POLYGON((0 0,0 1,1 1,1 0,0 0)) |
+------------+--------------------------------+