WITH Commuters AS (
    SELECT
        GE."ZipCode",
        SUM(CASE WHEN M."MetricID" = 'B08303_013E' THEN F."CensusValueByZip" ELSE 0 END +
            CASE WHEN M."MetricID" = 'B08303_012E' THEN F."CensusValueByZip" ELSE 0 END) AS "Num_Commuters_1Hr_Travel_Time"
    FROM
        CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."LU_GeographyExpanded" GE
    JOIN
        CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021_ByZip" F
        ON GE."ZipCode" = F."ZipCode"
    JOIN
        CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Dim_CensusMetrics" M
        ON F."MetricID" = M."MetricID"
    WHERE
        GE."PreferredStateAbbrev" = 'NY'
        AND (M."MetricID" = 'B08303_013E' OR M."MetricID" = 'B08303_012E') -- Metric IDs for commuters with 1+ hour travel time
    GROUP BY
        GE."ZipCode"
),

StateBenchmark AS (
    SELECT
        SB."StateAbbrev",
        SUM(SB."StateBenchmarkValue") AS "StateBenchmark_Over1HrTravelTime",
        SB."TotalStatePopulation"
    FROM
        CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_StateBenchmark_ACS2021" SB
    WHERE
        SB."MetricID" IN ('B08303_013E', 'B08303_012E')
        AND SB."StateAbbrev" = 'NY'
    GROUP BY
        SB."StateAbbrev", SB."TotalStatePopulation"
)

SELECT
    C."ZipCode",
    SUM(C."Num_Commuters_1Hr_Travel_Time") AS "Total_Commuters_1Hr_Travel_Time",
    SB."StateBenchmark_Over1HrTravelTime",
    SB."TotalStatePopulation",
FROM
    Commuters C
CROSS JOIN
    StateBenchmark SB
GROUP BY
    C."ZipCode", SB."StateBenchmark_Over1HrTravelTime", SB."TotalStatePopulation"
ORDER BY
    "Total_Commuters_1Hr_Travel_Time" DESC
LIMIT 1;


