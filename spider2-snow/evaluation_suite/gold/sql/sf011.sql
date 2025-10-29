WITH BlockGroupAndTractPop AS (
  SELECT
    T1."BlockGroupID",
    T1."StateCountyTractID",
    T2."CensusValue" AS "BlockGroupPopulation",
    SUM(T2."CensusValue") OVER (PARTITION BY T1."StateCountyTractID") AS "TractPopulation"
  FROM "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" AS T1
  JOIN "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" AS T2
    ON T1."BlockGroupID" = T2."BlockGroupID"
  WHERE
    T1."StateName" = 'New York' AND T2."MetricID" = 'B01003_001E'
)
SELECT
  "BlockGroupID",
  "BlockGroupPopulation" AS "census_value",
  "StateCountyTractID",
  "TractPopulation" AS "total_tract_population",
  "BlockGroupPopulation" / "TractPopulation" AS "population_ratio"
FROM BlockGroupAndTractPop
WHERE "TractPopulation" > 0