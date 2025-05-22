{{
  config(
    materialized = 'table',
    )
}}
SELECT
    c.concept_code AS source_code
    , c.concept_id AS source_concept_id
    , c.concept_name AS source_code_description
    , c.vocabulary_id AS source_vocabulary_id
    , c.domain_id AS source_domain_id
    , c.concept_class_id AS source_concept_class_id
    , c.valid_start_date AS source_valid_start_date
    , c.valid_end_date AS source_valid_end_date
    , c.invalid_reason AS source_invalid_reason
    , c.concept_id AS target_concept_id
    , c.concept_name AS target_concept_name
    , c.vocabulary_id AS target_vocabulary_id
    , c.domain_id AS target_domain_id
    , c.concept_class_id AS target_concept_class_id
    , c.invalid_reason AS target_invalid_reason
    , c.standard_concept AS target_standard_concept
FROM {{ ref( 'stg_vocabulary__concept') }} AS c
