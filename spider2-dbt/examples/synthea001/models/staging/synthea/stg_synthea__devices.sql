{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'devices') ) 
%}


WITH cte_devices_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','devices') }}
)

, cte_devices_rename AS (

    SELECT
        "start" AS device_start_datetime
        , "stop" AS device_stop_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , code AS device_code
        , "description" AS device_description
        , udi
    FROM cte_devices_lower

)

SELECT *
FROM cte_devices_rename
