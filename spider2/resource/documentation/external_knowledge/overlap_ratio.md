# Calculation Method: Overlap Ratio and Bank Location Data

This document describes the method used to calculate the number of bank institutions per postal code area (ZIP code) by combining geospatial data and bank location data, focusing on the overlap between postal code areas and census block groups.

## 1. Geospatial Intersection of Postal Code Areas and Census Block Groups
We are using two geographical units:
- **ZIP Code Areas**: Represented by geometries from the ZIP code boundaries dataset.
- **Census Block Groups**: Represented by geometries from the national census block groups dataset.

### Key Calculation:
- The method calculates the area of overlap between each ZIP code's geometry and each block group's geometry.
- The ratio of this intersection area to the total block group area is computed as the **overlap ratio**.

This overlap ratio represents the proportion of a block group that falls within a given ZIP code.

## 2. Bank Location Distribution Based on Overlap Ratio
The next step involves distributing the number of bank locations to the overlapping census block groups based on the calculated overlap ratio.

### Key Calculation:
- For each block group, the number of bank locations is proportionally assigned based on the overlap size. The total number of bank locations in a ZIP code is distributed to the block groups using the overlap ratio.

This provides the number of bank institutions for each block group, adjusted for the overlap with ZIP code areas.

## 3. Aggregation by ZIP Code Area
Finally, the results are aggregated by ZIP code to determine which postal code has the highest number of bank institutions.

### Key Calculation:
- The process involves grouping by ZIP code and finding the maximum number of bank locations per block group.
