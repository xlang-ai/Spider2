## Traffic Fatalities Info List 2015

### 1. `consecutive_number`

- Unique identifier for each accident.

### 2. `county`

- The county where the accident occurred.

### 3. `type_of_intersection`

- Describes the type of intersection where the accident took place.

### 4. `light_condition`

- The lighting condition during the accident, for example, daylight, dawn, dusk, etc.

### 5. `atmospheric_conditions_1`

- Describes the weather conditions at the time of the accident.

### 6. `hour_of_crash`

- The hour during which the accident occurred.

### 7. `functional_system`

- A classification of the roadway based on function, such as arterial, collector, etc.

### 8. `related_factors` (alias for `related_factors_crash_level_1`)

- Factors related to the crash at a macro level.

### 9. `delay_to_hospital`

- Calculated as the time delay between the accident and EMS arrival at the hospital.

  - Formula: `hour_of_ems_arrival_at_hospital - hour_of_crash`

  - Conditions:

​    - Valid when `hour_of_ems_arrival_at_hospital` is between 0 and 23.

​    - Otherwise `NULL`.

### 10. `delay_to_scene`

- Calculated as the time delay between the accident and arrival at the scene.

  - Formula: `hour_of_arrival_at_scene - hour_of_crash`

  - Conditions:

​    - Valid when `hour_of_arrival_at_scene` is between 0 and 23.

​    - Otherwise `NULL`.

### 11. `age`

- Age of the individual involved in the accident.

### 12. `person_type`

- The type of person involved, e.g., driver, pedestrian, etc.

### 13. `seating_position`

- Where the person was seated in the vehicle.

### 14. `restraint`

- A calculated value indicating the level of restraint system helmet use:

  - `0` if 0.

  - `0.33` if 1.

  - `0.67` if 2.

  - `1.0` if 3.

  - Default to `0.5` for unspecified cases.

### 15. `survived`

- A binary value indicating if the person survived:

  - `1` if injury severity is 4 (survived),

  - `0` otherwise.

### 16. `rollover`

- A binary value indicating if a rollover occurred:

  - `0` for no rollover.

  - `1` for a rollover event.



### 17. `airbag`

- A binary indicator for airbag deployment:

  - `1` if deployed (values between 1 and 9).

  - `0` if not deployed.



### 18. `alcohol`

- A binary indicator for alcohol involvement:

  - `1` if alcohol involvement contains "Yes".

  - `0` otherwise.



### 19. `drugs`

- A binary indicator for drug involvement:

  - `1` if drug involvement contains "Yes".

  - `0` otherwise.



### 20. `related_factors_person_level1`

- Factors related to the individual involved in the accident.



### 21. `travel_speed`

- The speed at which the vehicle was traveling.



### 22. `speeding_related`

- A binary value indicating if the accident was speeding-related:

  - `1` if contains "Yes".

  - `0` otherwise.

### 23. `extent_of_damage`

- Describes how extensive the vehicle damage was.

### 24. `body_type`

- Type of vehicle body.

### 25. `vehicle_removal`

- Indicates whether the vehicle was removed from the scene.

### 26. `manner_of_collision`

- A capped value of the manner of collision:

  - Capped at `11` for values over 11.

### 27. `roadway_surface_condition`

- A capped value for the condition of the roadway surface:

  - Capped at `8` for values over 11.

### 28. `first_harmful_event`

- Describes the first harmful event in the crash:

  - Original value if less than 90, else 0.

### 29. `most_harmful_event`

- Describes the most harmful event in the crash:

  - Original value if less than 90, else 0.