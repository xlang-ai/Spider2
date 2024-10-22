SELECT
    person_id
    , gender_concept_id
    , year_of_birth
    , month_of_birth
    , day_of_birth
    , birth_datetime
    , race_concept_id
    , ethnicity_concept_id
    , location_id
    , provider_id
    , care_site_id
    , person_source_value
    , gender_source_value
    , gender_source_concept_id
    , race_source_value
    , race_source_concept_id
    , ethnicity_source_value
    , ethnicity_source_concept_id
FROM {{ ref('int__person') }}
