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