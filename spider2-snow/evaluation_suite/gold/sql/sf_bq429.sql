WITH income_diff_by_zip AS (
    SELECT
        T1."geo_id",
        ABS(T2."median_income" - T1."median_income") AS income_difference
    FROM "CENSUS_BUREAU_ACS_2"."CENSUS_BUREAU_ACS"."ZCTA5_2015_5YR" AS T1
    JOIN "CENSUS_BUREAU_ACS_2"."CENSUS_BUREAU_ACS"."ZCTA5_2018_5YR" AS T2
        ON T1."geo_id" = T2."geo_id"
    WHERE T1."median_income" IS NOT NULL AND T2."median_income" IS NOT NULL
),
vulnerable_pop_by_zip AS (
    SELECT
        "geo_id",
        ("employed_wholesale_trade" * 0.38423645320197042 +
         ("employed_agriculture_forestry_fishing_hunting_mining" + "employed_construction") * 0.48071410777129553 +
         "employed_arts_entertainment_recreation_accommodation_food" * 0.89455676291236841 +
         "employed_information" * 0.31315240083507306 +
         "employed_retail_trade" * 0.51) AS vulnerable_employees
    FROM "CENSUS_BUREAU_ACS_2"."CENSUS_BUREAU_ACS"."ZCTA5_2017_5YR"
    WHERE
        "employed_wholesale_trade" IS NOT NULL AND
        "employed_agriculture_forestry_fishing_hunting_mining" IS NOT NULL AND
        "employed_construction" IS NOT NULL AND
        "employed_arts_entertainment_recreation_accommodation_food" IS NOT NULL AND
        "employed_information" IS NOT NULL AND
        "employed_retail_trade" IS NOT NULL
),
joined_data AS (
    SELECT
        T3."state_name",
        T1.income_difference,
        T2.vulnerable_employees
    FROM income_diff_by_zip AS T1
    JOIN vulnerable_pop_by_zip AS T2
        ON T1."geo_id" = T2."geo_id"
    JOIN "CENSUS_BUREAU_ACS_2"."GEO_US_BOUNDARIES"."ZIP_CODES" AS T3
        ON T1."geo_id" = T3."zip_code"
)
SELECT
    "state_name",
    AVG(income_difference) AS avg_income_diff,
    AVG(vulnerable_employees) AS avg_vulnerable_employees
FROM joined_data
GROUP BY "state_name"
ORDER BY avg_income_diff DESC
LIMIT 5