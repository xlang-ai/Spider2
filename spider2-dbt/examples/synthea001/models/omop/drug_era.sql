-- Code taken from:
-- https://github.com/OHDSI/ETL-CMS/blob/master/SQL/create_CDMv5_drug_era_non_stockpile.sql

WITH ctePreDrugTarget AS (
    -- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
    SELECT
        d.drug_exposure_id
        , d.person_id
        , c.concept_id AS ingredient_concept_id
        , d.drug_exposure_start_date
        , d.days_supply
        , COALESCE(
            NULLIF(drug_exposure_end_date, NULL)
            , NULLIF(
                drug_exposure_start_date + days_supply * INTERVAL '1 day'
                , drug_exposure_start_date
            )
            , drug_exposure_start_date + INTERVAL '1 day'
        ) AS drug_exposure_end_date
    FROM {{ ref ('drug_exposure') }} AS d
    INNER JOIN {{ ref ('stg_vocabulary__concept_ancestor') }} AS ca
        ON d.drug_concept_id = ca.descendant_concept_id
    INNER JOIN {{ ref ('stg_vocabulary__concept') }} AS c
        ON ca.ancestor_concept_id = c.concept_id
    WHERE
        c.vocabulary_id = 'RxNorm'
        AND c.concept_class_id = 'Ingredient'
        AND d.drug_concept_id != 0
        AND COALESCE(d.days_supply, 0) >= 0
)

, cteSubExposureEndDates AS (
    SELECT
        person_id
        , ingredient_concept_id
        , event_date AS end_date
    FROM
        (
            SELECT
                person_id
                , ingredient_concept_id
                , event_date
                , event_type
                , MAX(start_ordinal) OVER (
                    PARTITION BY person_id, ingredient_concept_id
                    ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING
                ) AS start_ordinal
                , ROW_NUMBER() OVER (
                    PARTITION BY person_id, ingredient_concept_id
                    ORDER BY event_date, event_type
                ) AS overall_ord
            FROM (
                SELECT
                    person_id
                    , ingredient_concept_id
                    , drug_exposure_start_date AS event_date
                    , -1 AS event_type
                    , ROW_NUMBER() OVER (
                        PARTITION BY person_id, ingredient_concept_id
                        ORDER BY drug_exposure_start_date
                    ) AS start_ordinal
                FROM ctePreDrugTarget

                UNION ALL

                SELECT
                    person_id
                    , ingredient_concept_id
                    , drug_exposure_end_date
                    , 1 AS event_type
                    , NULL AS start_ordinal
                FROM ctePreDrugTarget
            ) AS RAWDATA
        ) AS e
    WHERE (2 * e.start_ordinal) - e.overall_ord = 0
)

, cteDrugExposureEnds AS (
    SELECT
        dt.person_id
        , dt.ingredient_concept_id
        , dt.drug_exposure_start_date
        , MIN(e.end_date) AS drug_sub_exposure_end_date
    FROM ctePreDrugTarget AS dt
    INNER JOIN cteSubExposureEndDates AS e
        ON
            dt.person_id = e.person_id
            AND dt.ingredient_concept_id = e.ingredient_concept_id
            AND dt.drug_exposure_start_date <= e.end_date
    GROUP BY
        dt.drug_exposure_id
        , dt.person_id
        , dt.ingredient_concept_id
        , dt.drug_exposure_start_date
)

, cteSubExposures AS (
    SELECT
        ROW_NUMBER()
            OVER (
                PARTITION BY
                    person_id
                    , ingredient_concept_id
                    , drug_sub_exposure_end_date
                ORDER BY person_id
            )
        AS row_number
        , person_id
        , ingredient_concept_id
        , MIN(drug_exposure_start_date) AS drug_sub_exposure_start_date
        , drug_sub_exposure_end_date
        , COUNT(*) AS drug_exposure_count
    FROM cteDrugExposureEnds
    GROUP BY person_id, ingredient_concept_id, drug_sub_exposure_end_date
)

, cteFinalTarget AS (
    SELECT
        row_number
        , person_id
        , ingredient_concept_id
        , drug_sub_exposure_start_date
        , drug_sub_exposure_end_date
        , drug_exposure_count
        , EXTRACT(
            DAY FROM drug_sub_exposure_end_date - drug_sub_exposure_start_date
        ) AS days_exposed
    FROM cteSubExposures
)

, cteEndDates AS (
    SELECT
        person_id
        , ingredient_concept_id
        , event_date - INTERVAL '30 day' AS end_date
    FROM
        (
            SELECT
                person_id
                , ingredient_concept_id
                , event_date
                , event_type
                , MAX(start_ordinal) OVER (
                    PARTITION BY person_id, ingredient_concept_id
                    ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING
                ) AS start_ordinal
                , ROW_NUMBER() OVER (
                    PARTITION BY person_id, ingredient_concept_id
                    ORDER BY event_date, event_type
                ) AS overall_ord
            FROM (
                SELECT
                    person_id
                    , ingredient_concept_id
                    , drug_sub_exposure_start_date AS event_date
                    , -1 AS event_type
                    , ROW_NUMBER() OVER (
                        PARTITION BY person_id, ingredient_concept_id
                        ORDER BY drug_sub_exposure_start_date
                    ) AS start_ordinal
                FROM cteFinalTarget

                UNION ALL

                SELECT
                    person_id
                    , ingredient_concept_id
                    , drug_sub_exposure_end_date + INTERVAL '30 day' AS event_date
                    , 1 AS event_type
                    , NULL AS start_ordinal
                FROM cteFinalTarget
            ) AS RAWDATA
        ) AS e
    WHERE (2 * e.start_ordinal) - e.overall_ord = 0
)

, cteDrugEraEnds AS (
    SELECT
        ft.person_id
        , ft.ingredient_concept_id AS drug_concept_id
        , ft.drug_sub_exposure_start_date
        , MIN(e.end_date) AS drug_era_end_date
        , drug_exposure_count
        , days_exposed
    FROM cteFinalTarget AS ft
    INNER JOIN cteEndDates AS e
        ON
            ft.person_id = e.person_id
            AND ft.ingredient_concept_id = e.ingredient_concept_id
            AND ft.drug_sub_exposure_start_date <= e.end_date
    GROUP BY
        ft.person_id
        , ft.ingredient_concept_id
        , ft.drug_sub_exposure_start_date
        , drug_exposure_count
        , days_exposed
)

, cteDrugEra AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY person_id) AS drug_era_id
        , person_id
        , drug_concept_id
        , MIN(drug_sub_exposure_start_date) AS drug_era_start_date
        , {{ dbt.safe_cast("drug_era_end_date", api.Column.translate_type("date")) }} AS drug_era_end_date
        , SUM(drug_exposure_count) AS drug_exposure_count
        , MIN(drug_sub_exposure_start_date) AS min_drug_sub_exposure_start_date
        , SUM(days_exposed) AS sum_days_exposed
    FROM cteDrugEraEnds
    GROUP BY person_id, drug_concept_id, drug_era_end_date
)

SELECT
    drug_era_id
    , person_id
    , drug_concept_id
    , drug_era_start_date
    , drug_era_end_date
    , drug_exposure_count
    , {{ dbt.datediff(
            dbt.safe_cast("min_drug_sub_exposure_start_date", api.Column.translate_type("date")),
            dbt.safe_cast("drug_era_end_date", api.Column.translate_type("date")), 
            "day") 
    }} - sum_days_exposed AS gap_days
FROM cteDrugEra
