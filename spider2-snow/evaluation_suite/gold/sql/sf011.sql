 WITH TractPop AS (
    SELECT
        CG."BlockGroupID",
        FCV."CensusValue",
        CG."StateCountyTractID",
        CG."BlockGroupPolygon"
    FROM
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Dim_CensusGeography" CG
    JOIN
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021" FCV
        ON CG."BlockGroupID" = FCV."BlockGroupID"
    WHERE
        CG."StateAbbrev" = 'NY'
        AND FCV."MetricID" = 'B01003_001E'
),

TractGroup AS (
    SELECT
        CG."StateCountyTractID",
        SUM(FCV."CensusValue") AS "TotalTractPop"
    FROM
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Dim_CensusGeography" CG
    JOIN
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021" FCV
        ON CG."BlockGroupID" = FCV."BlockGroupID"
    WHERE
        CG."StateAbbrev" = 'NY'
        AND FCV."MetricID" = 'B01003_001E'
    GROUP BY
        CG."StateCountyTractID"
)

SELECT
    TP."BlockGroupID",
    TP."CensusValue",
    TP."StateCountyTractID",
    TG."TotalTractPop",
    CASE WHEN TG."TotalTractPop" <> 0 THEN TP."CensusValue" / TG."TotalTractPop" ELSE 0 END AS "BlockGroupRatio"
FROM
    TractPop TP
JOIN
    TractGroup TG
    ON TP."StateCountyTractID" = TG."StateCountyTractID";