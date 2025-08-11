{# This bit of SQL gets reused several times in the OMOP layer #}
SELECT
    e.patient_id
    , e.encounter_id
    , pr.provider_id
FROM {{ ref ('stg_synthea__encounters') }} AS e
INNER JOIN {{ ref ('provider') }} AS pr
    ON e.provider_id = pr.provider_source_value
