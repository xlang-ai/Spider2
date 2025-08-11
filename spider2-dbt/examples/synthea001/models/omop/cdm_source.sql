SELECT
    'dbt-synthea' AS cdm_source_name
    , 'dbt-synthea' AS cdm_source_abbreviation
    , 'OHDSI' AS cdm_holder
    , 'An OMOP CDM derived from a Synthea dataset using dbt.' AS source_description
    , 'https://synthetichealth.github.io/synthea/' AS source_documentation_reference
    , 'https://github.com/OHDSI/dbt-synthea' AS cdm_etl_reference
    , current_date AS source_release_date
    , current_date AS cdm_release_date
    , '5.4' AS cdm_version
    , vocabulary_version
    , 798878 AS cdm_version_concept_id
FROM {{ ref('stg_vocabulary__vocabulary') }}
WHERE vocabulary_id = 'None'
