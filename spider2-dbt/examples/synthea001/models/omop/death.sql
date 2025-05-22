-- NB:
-- We observe death records in both the encounters.csv and observations.csv file.
-- To find the death records in observations, use code = '69453-9'. This is a LOINC code
-- that represents an observation of the US standard certificate of death.  To find the
-- corresponding cause of death, we would need to join to conditions on patient and description
-- (specifically conditions.description = observations.value).  Instead, we can use the encounters table.
-- Encounters.code = '308646001' is the SNOMED observation of death certification.
-- The reasoncode column is the SNOMED code for the condition that caused death, so by using encounters
-- we get both the code for the death certification and the corresponding cause of death.

SELECT
    p.person_id
    , {{ dbt.safe_cast("e.encounter_start_datetime", api.Column.translate_type("date")) }} AS death_date
    , e.encounter_start_datetime AS death_datetime
    , 32817 AS death_type_concept_id
    , srctostdvm.target_concept_id AS cause_concept_id
    , e.encounter_reason_code AS cause_source_value
    , srctostdvm.source_concept_id AS cause_source_concept_id
FROM {{ ref('stg_synthea__encounters') }} AS e
INNER JOIN {{ ref('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        e.encounter_reason_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Condition'
        AND srctostdvm.source_domain_id = 'Condition'
        AND srctostdvm.target_vocabulary_id = 'SNOMED'
        AND srctostdvm.source_vocabulary_id = 'SNOMED'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref('person') }} AS p
    ON e.patient_id = p.person_source_value
WHERE e.encounter_code = '308646001'
