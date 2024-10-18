# Score Intervals and Coordinates Logic

## Score Delta Intervals

To categorize the score deltas into intervals, the following conditions are used:

- **<-20**: When `score_delta < -20`
- **-20 — -11**: When `score_delta` is between -20 (inclusive) and -10 (exclusive)
- **-10 — -1**: When `score_delta` is between -10 (inclusive) and 0 (exclusive)
- **0**: When `score_delta` equals 0
- **1 — 10**: When `score_delta` is between 1 (inclusive) and 10 (inclusive)
- **11 — 20**: When `score_delta` is between 11 (exclusive) and 20 (inclusive)
- **>20**: When `score_delta > 20`

These intervals help in analyzing the performance based on the difference in team scores.

## X and Y Coordinates Calculation

Coordinates are adjusted based on the `event_coord_x` and `event_coord_y` values as follows:

- **X Coordinate**: 
  - If `event_coord_x < 564`: Use `event_coord_x` directly.
  - Otherwise: Calculate as `1128 - event_coord_x`.

- **Y Coordinate**: 
  - If `event_coord_x < 564`: Calculate as `600 - event_coord_y`.
  - Otherwise: Use `event_coord_y` directly.
