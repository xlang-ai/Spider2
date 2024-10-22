SELECT
    i.patient_id
    , i.encounter_id
    , srctostdvm.target_concept_id AS drug_concept_id
    , i.immunization_date AS drug_exposure_start_date
    , i.immunization_date AS drug_exposure_start_datetime
    , i.immunization_date AS drug_exposure_end_date
    , i.immunization_date AS drug_exposure_end_datetime
    , i.immunization_date AS verbatim_end_date
    , 32827 AS drug_type_concept_id
    , cast(null AS varchar) AS stop_reason
    , cast(null AS integer) AS refills
    , cast(null AS integer) AS quantity
    , cast(null AS integer) AS days_supply
    , cast(null AS varchar) AS sig
    , 0 AS route_concept_id
    , '0' AS lot_number
    , i.immunization_code AS drug_source_value
    , srctosrcvm.source_concept_id AS drug_source_concept_id
    , cast(null AS varchar) AS route_source_value
    , cast(null AS varchar) AS dose_unit_source_value
FROM {{ ref ('stg_synthea__immunizations') }} AS i
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        i.immunization_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Drug'
        AND srctostdvm.target_vocabulary_id = 'CVX'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        i.immunization_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'CVX'
