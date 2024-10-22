SELECT
    row_number() OVER (ORDER BY (SELECT null)) AS provider_id
    , provider_name
    , cast(null AS varchar(20)) AS npi
    , cast(null AS varchar(20)) AS dea
    , 38004446 AS specialty_concept_id
    , cast(null AS integer) AS care_site_id
    , cast(null AS integer) AS year_of_birth
    , CASE upper(provider_gender)
        WHEN 'M' THEN 8507
        WHEN 'F' THEN 8532
    END AS gender_concept_id
    , provider_id AS provider_source_value
    , provider_specialty AS specialty_source_value
    , 38004446 AS specialty_source_concept_id
    , provider_gender AS gender_source_value
    , CASE upper(provider_gender)
        WHEN 'M' THEN 8507
        WHEN 'F' THEN 8532
    END AS gender_source_concept_id
FROM {{ ref( 'stg_synthea__providers') }}
