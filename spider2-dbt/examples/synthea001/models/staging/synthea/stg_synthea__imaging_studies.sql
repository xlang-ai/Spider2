{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'imaging_studies') ) 
%}


WITH cte_imaging_studies_lower AS (

    SELECT
        {{ lowercase_columns(column_names) }}
    FROM {{ source('synthea','imaging_studies') }}
)

, cte_imaging_studies_rename AS (

    SELECT
        "id" AS imaging_id
        , "date" AS imaging_datetime
        , patient AS patient_id
        , encounter AS encounter_id
        , series_uid
        , bodysite_code
        , bodysite_description
        , modality_code
        , modality_description
        , instance_uid
        , sop_code
        , sop_description
        , procedure_code AS imaging_procedure_code
    FROM cte_imaging_studies_lower

)

SELECT *
FROM cte_imaging_studies_rename
