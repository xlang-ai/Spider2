WITH cte AS (
    SELECT
        co.condition_occurrence_id
        , ppp.payer_plan_period_id
        , coalesce(
            sum(CASE WHEN ct.transfer_type = '1' THEN {{ dbt.safe_cast("ct.transaction_amount", api.Column.translate_type("decimal")) }} END)
            , 0
        )
        AS payer_paid
        , coalesce(
            sum(CASE WHEN ct.transfer_type = 'p' THEN {{ dbt.safe_cast("ct.transaction_amount", api.Column.translate_type("decimal")) }} END)
            , 0
        )
        AS patient_paid
    FROM {{ ref ('stg_synthea__conditions') }} AS cn
    INNER JOIN {{ ref ('stg_synthea__encounters') }} AS e
        ON
            cn.encounter_id = e.encounter_id
            AND cn.patient_id = e.patient_id
    INNER JOIN {{ ref ('person') }} AS p
        ON cn.patient_id = p.person_source_value
    INNER JOIN {{ ref ('visit_occurrence') }} AS vo
        ON
            p.person_id = vo.person_id
            AND e.patient_id = vo.visit_source_value
    INNER JOIN {{ ref ('condition_occurrence') }} AS co
        ON
            cn.condition_code = co.condition_source_value
            AND vo.visit_occurrence_id = co.visit_occurrence_id
            AND vo.person_id = co.person_id
    LEFT JOIN {{ ref ('payer_plan_period') }} AS ppp
        ON
            p.person_id = ppp.person_id
            AND co.condition_start_date >= ppp.payer_plan_period_start_date
            AND co.condition_start_date <= ppp.payer_plan_period_end_date
    INNER JOIN {{ ref ('stg_synthea__claims') }} AS ca
        ON
            cn.patient_id = ca.patient_id
            AND cn.condition_code = ca.diagnosis_1
            AND cn.condition_start_date = ca.current_illness_date
            AND e.encounter_id = ca.encounter_id
            AND e.provider_id = ca.provider_id
            AND e.payer_id = ca.primary_patient_insurance_id
            AND e.encounter_start_datetime = ca.service_date
    INNER JOIN {{ ref ('stg_synthea__claims_transactions') }} AS ct
        ON
            ca.claim_id = ct.claim_id
            AND cn.patient_id = ct.patient_id
            AND e.encounter_id = ct.encounter_id
            AND e.provider_id = ct.provider_id
    WHERE ct.transfer_type IN ('1', 'p')
    GROUP BY co.condition_occurrence_id, ppp.payer_plan_period_id
)

SELECT
    condition_occurrence_id AS cost_event_id
    , 'condition' AS cost_domain_id
    , 32814 AS cost_type_concept_id
    , 44818668 AS currency_concept_id
    , {{ dbt.safe_cast("payer_paid ", api.Column.translate_type("decimal")) }} + {{ dbt.safe_cast("patient_paid", api.Column.translate_type("decimal")) }} AS total_charge
    , {{ dbt.safe_cast("payer_paid ", api.Column.translate_type("decimal")) }} + {{ dbt.safe_cast("patient_paid", api.Column.translate_type("decimal")) }} AS total_cost
    , {{ dbt.safe_cast("payer_paid ", api.Column.translate_type("decimal")) }} + {{ dbt.safe_cast("patient_paid", api.Column.translate_type("decimal")) }} AS total_paid
    , payer_paid AS paid_by_payer
    , patient_paid AS paid_by_patient
    , cast(null AS numeric) AS paid_patient_copay
    , cast(null AS numeric) AS paid_patient_coinsurance
    , cast(null AS numeric) AS paid_patient_deductible
    , payer_paid AS paid_by_primary
    , cast(null AS numeric) AS paid_ingredient_cost
    , cast(null AS numeric) AS paid_dispensing_fee
    , payer_plan_period_id
    , cast(null AS numeric) AS amount_allowed
    , 0 AS revenue_code_concept_id
    , 'unknown / unknown' AS revenue_code_source_value
    , 0 AS drg_concept_id
    , '000' AS drg_source_value
FROM cte
