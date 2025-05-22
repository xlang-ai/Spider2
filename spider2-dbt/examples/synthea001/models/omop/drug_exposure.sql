WITH all_drugs AS (
    SELECT * FROM {{ ref('int__drug_medications') }}
    UNION ALL
    SELECT * FROM {{ ref('int__drug_immunisations') }}
)

SELECT
    row_number() OVER (ORDER BY p.person_id) AS drug_exposure_id
    , p.person_id
    , drug_concept_id
    , {{ dbt.safe_cast("drug_exposure_start_date", api.Column.translate_type("date")) }} AS drug_exposure_start_date
    , drug_exposure_start_datetime
    , {{ dbt.safe_cast("drug_exposure_end_date", api.Column.translate_type("date")) }} AS drug_exposure_end_date
    , drug_exposure_end_datetime
    , {{ dbt.safe_cast("verbatim_end_date", api.Column.translate_type("date")) }} AS verbatim_end_date
    , drug_type_concept_id
    , stop_reason
    , refills
    , quantity
    , days_supply
    , sig
    , route_concept_id
    , lot_number
    , pr.provider_id
    , fv.visit_occurrence_id_new AS visit_occurrence_id
    , fv.visit_occurrence_id_new + 1000000 AS visit_detail_id
    , drug_source_value
    , drug_source_concept_id
    , route_source_value
    , dose_unit_source_value
FROM
    all_drugs AS ad
LEFT JOIN {{ ref ('int__final_visit_ids') }} AS fv
    ON ad.encounter_id = fv.encounter_id
LEFT JOIN {{ ref ('stg_synthea__encounters') }} AS e
    ON
        ad.encounter_id = e.encounter_id
        AND ad.patient_id = e.patient_id
LEFT JOIN {{ ref ('provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
INNER JOIN {{ ref ('person') }} AS p
    ON ad.patient_id = p.person_source_value
