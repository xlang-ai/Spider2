SELECT DISTINCT
    de.drug_exposure_id AS cost_event_id
    , 'Drug' AS cost_domain_id
    , 32814 AS cost_type_concept_id
    , 44818668 AS currency_concept_id
    , {{ dbt.safe_cast("e.total_encounter_cost", api.Column.translate_type("decimal")) }} + {{ dbt.safe_cast("m.medication_base_cost", api.Column.translate_type("decimal")) }} AS total_charge
    , {{ dbt.safe_cast("e.total_encounter_cost", api.Column.translate_type("decimal")) }} + {{ dbt.safe_cast("m.medication_base_cost", api.Column.translate_type("decimal")) }} AS total_cost
    , {{ dbt.safe_cast("e.encounter_payer_coverage", api.Column.translate_type("decimal")) }} + {{ dbt.safe_cast("m.medication_base_cost", api.Column.translate_type("decimal")) }} AS total_paid
    , e.encounter_payer_coverage AS paid_by_payer
    , {{ dbt.safe_cast("e.total_encounter_cost", api.Column.translate_type("decimal")) }}
    + {{ dbt.safe_cast("m.medication_base_cost", api.Column.translate_type("decimal")) }}
    - {{ dbt.safe_cast("e.encounter_payer_coverage", api.Column.translate_type("decimal")) }} AS paid_by_patient
    , cast(null AS numeric) AS paid_patient_copay
    , cast(null AS numeric) AS paid_patient_coinsurance
    , cast(null AS numeric) AS paid_patient_deductible
    , cast(null AS numeric) AS paid_by_primary
    , cast(null AS numeric) AS paid_ingredient_cost
    , cast(null AS numeric) AS paid_dispensing_fee
    , ppp.payer_plan_period_id
    , cast(null AS numeric) AS amount_allowed
    , 0 AS revenue_code_concept_id
    , 'UNKNOWN / UNKNOWN' AS revenue_code_source_value
    , 0 AS drg_concept_id
    , '000' AS drg_source_value
FROM {{ ref ('stg_synthea__medications') }} AS m
INNER JOIN {{ ref ('stg_synthea__encounters') }} AS e
    ON
        m.encounter_id = e.encounter_id
        AND m.patient_id = e.patient_id
INNER JOIN {{ ref ('person') }} AS p
    ON m.patient_id = p.person_source_value
INNER JOIN {{ ref ('visit_occurrence') }} AS vo
    ON
        p.person_id = vo.person_id
        AND e.encounter_id = vo.visit_source_value
INNER JOIN {{ ref ('drug_exposure') }} AS de
    ON
        m.medication_code = de.drug_source_value
        AND vo.visit_occurrence_id = de.visit_occurrence_id
        AND vo.person_id = de.person_id
LEFT JOIN {{ ref ('payer_plan_period') }} AS ppp
    ON
        p.person_id = ppp.person_id
        AND de.drug_exposure_start_date >= ppp.payer_plan_period_start_date
        AND de.drug_exposure_start_date <= ppp.payer_plan_period_end_date
