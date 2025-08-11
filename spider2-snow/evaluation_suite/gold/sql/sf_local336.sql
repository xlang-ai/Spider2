SELECT
  overtake_type,
  COUNT(*) AS overtake_count
FROM (
  SELECT DISTINCT
    lap_positions."race_id",
    lap_positions."driver_id" AS overtaking_driver_id,
    lap_positions."lap",
    cars_behind_this_lap."driver_id" AS overtaken_driver_id,
    CASE
      WHEN retirements."driver_id" IS NOT NULL THEN 'R'
      WHEN pit_stops."lap" = lap_positions."lap" THEN 'P'
      WHEN pit_stops."milliseconds" > overtaking_lap_times."running_milliseconds" - overtaken_lap_times."running_milliseconds" THEN 'P'
      WHEN lap_positions."lap" = 1 AND (previous_lap."position" - cars_behind_this_lap_results."grid") <= 2 THEN 'S'
      ELSE 'T'
    END AS overtake_type
  FROM F1.F1.LAP_POSITIONS lap_positions
    INNER JOIN F1.F1.RACES_EXT AS races
      ON races."race_id" = lap_positions."race_id"
      AND races."is_pit_data_available" = 1
    INNER JOIN F1.F1.LAP_POSITIONS AS previous_lap
      ON previous_lap."race_id" = lap_positions."race_id"
      AND previous_lap."driver_id" = lap_positions."driver_id"
      AND previous_lap."lap" = lap_positions."lap" - 1
    INNER JOIN F1.F1.LAP_POSITIONS AS cars_behind_this_lap
      ON cars_behind_this_lap."race_id" = lap_positions."race_id"
      AND cars_behind_this_lap."lap" = lap_positions."lap"
      AND cars_behind_this_lap."position" > lap_positions."position"
    LEFT JOIN F1.F1.RESULTS AS cars_behind_this_lap_results
      ON cars_behind_this_lap_results."race_id" = lap_positions."race_id"
      AND cars_behind_this_lap_results."driver_id" = cars_behind_this_lap."driver_id"
    LEFT JOIN F1.F1.LAP_POSITIONS AS cars_behind_last_lap
      ON cars_behind_last_lap."race_id" = lap_positions."race_id"
      AND cars_behind_last_lap."lap" = lap_positions."lap" - 1
      AND cars_behind_last_lap."driver_id" = cars_behind_this_lap."driver_id"
      AND cars_behind_last_lap."position" > previous_lap."position"
    LEFT JOIN F1.F1.RETIREMENTS AS retirements
      ON retirements."race_id" = lap_positions."race_id"
      AND retirements."lap" = lap_positions."lap"
      AND retirements."driver_id" = cars_behind_this_lap."driver_id"
    LEFT JOIN F1.F1.PIT_STOPS AS pit_stops
      ON pit_stops."race_id" = lap_positions."race_id"
      AND pit_stops."lap" BETWEEN lap_positions."lap" - 1 AND lap_positions."lap"
      AND pit_stops."driver_id" = cars_behind_this_lap."driver_id"
    LEFT JOIN F1.F1.LAP_TIMES_EXT AS overtaking_lap_times
      ON overtaking_lap_times."race_id" = lap_positions."race_id"
      AND overtaking_lap_times."driver_id" = lap_positions."driver_id"
      AND overtaking_lap_times."lap" = pit_stops."lap" - 1
    LEFT JOIN F1.F1.LAP_TIMES_EXT AS overtaken_lap_times
      ON overtaken_lap_times."race_id" = lap_positions."race_id"
      AND overtaken_lap_times."driver_id" = pit_stops."driver_id"
      AND overtaken_lap_times."lap" = pit_stops."lap" - 1
  WHERE
    cars_behind_last_lap."driver_id" IS NULL
    AND lap_positions."lap" <= 5 /* Filter for the first five laps */
) AS overtakes
GROUP BY overtake_type;
