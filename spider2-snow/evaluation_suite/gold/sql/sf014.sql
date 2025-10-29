WITH ZipCommuters AS (
    SELECT
        f."ZipCode",
        SUM(f."CensusValueByZip") AS "TotalCommutersOver1Hour"
    FROM CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021_ByZip" AS f
    JOIN CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."LU_GeographyExpanded" AS l ON f."ZipCode" = l."ZipCode"
    WHERE l."PreferredStateAbbrev" = 'NY'
      AND f."MetricID" IN ('B08303_012E', 'B08303_013E')
    GROUP BY f."ZipCode"
),
StateBenchmark AS (
    SELECT
        SUM("StateBenchmarkValue") AS "StateBenchmarkOver1Hour"
    FROM CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_StateBenchmark_ACS2021"
    WHERE "StateAbbrev" = 'NY'
      AND "MetricID" IN ('B08303_012E', 'B08303_013E')
),
StatePopulation AS (
    SELECT
        MAX("TotalStatePopulation") AS "StatePopulation"
    FROM CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_StateBenchmark_ACS2021"
    WHERE "StateAbbrev" = 'NY'
)
SELECT
    zc."ZipCode" AS "zip_code",
    zc."TotalCommutersOver1Hour" AS "total_commuters_over_one_hour",
    sb."StateBenchmarkOver1Hour" AS "state_benchmark_for_this_duration",
    sp."StatePopulation" AS "state_population"
FROM ZipCommuters zc
CROSS JOIN StateBenchmark sb
CROSS JOIN StatePopulation sp
ORDER BY "total_commuters_over_one_hour" DESC
LIMIT 1;