SELECT
    m.patient_id
    , m.encounter_id
    , srctostdvm.target_concept_id AS drug_concept_id
    , m.medication_start_datetime AS drug_exposure_start_date
    , m.medication_start_datetime AS drug_exposure_start_datetime
    , coalesce(
        m.medication_stop_datetime, m.medication_start_datetime
    ) AS drug_exposure_end_date
    , coalesce(
        m.medication_stop_datetime, m.medication_start_datetime
    ) AS drug_exposure_end_datetime
    , m.medication_stop_datetime AS verbatim_end_date
    , 32838 AS drug_type_concept_id
    , cast(null AS varchar) AS stop_reason
    , cast(null AS integer) AS refills
    , cast(null AS integer) AS quantity
    , {{ dbt.datediff(
            dbt.safe_cast("m.medication_start_datetime", api.Column.translate_type("date")),
            dbt.safe_cast("m.medication_stop_datetime", api.Column.translate_type("date")), 
            "day") 
    }} AS days_supply
    , cast(null AS varchar) AS sig
    , 0 AS route_concept_id
    , '0' AS lot_number
    , m.medication_code AS drug_source_value
    , srctosrcvm.source_concept_id AS drug_source_concept_id
    , cast(null AS varchar) AS route_source_value
    , cast(null AS varchar) AS dose_unit_source_value
FROM {{ ref ('stg_synthea__medications') }} AS m
INNER JOIN {{ ref ('int__source_to_standard_vocab_map') }} AS srctostdvm
    ON
        m.medication_code = srctostdvm.source_code
        AND srctostdvm.target_domain_id = 'Drug'
        AND srctostdvm.target_vocabulary_id = 'RxNorm'
        AND srctostdvm.target_standard_concept = 'S'
        AND srctostdvm.target_invalid_reason IS null
INNER JOIN {{ ref ('int__source_to_source_vocab_map') }} AS srctosrcvm
    ON
        m.medication_code = srctosrcvm.source_code
        AND srctosrcvm.source_vocabulary_id = 'RxNorm'
