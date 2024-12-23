WITH HighestReleases AS (
    SELECT
        HR."Name",
        HR."Version"
    FROM (
        SELECT
            "Name",
            "Version",
            ROW_NUMBER() OVER (
                PARTITION BY "Name"
                ORDER BY 
                    TO_NUMBER(PARSE_JSON("VersionInfo"):"Ordinal") DESC
            ) AS RowNumber
        FROM
            DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS
        WHERE
            "System" = 'NPM'
            AND TO_BOOLEAN(PARSE_JSON("VersionInfo"):"IsRelease") = TRUE
    ) AS HR
    WHERE HR.RowNumber = 1
),
PVP AS (
    SELECT
        PVP."Name", 
        PVP."Version", 
        PVP."ProjectType", 
        PVP."ProjectName"
    FROM
        DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT AS PVP
    JOIN
        HighestReleases AS HR
    ON
        PVP."Name" = HR."Name"
        AND PVP."Version" = HR."Version"
    WHERE
        PVP."System" = 'NPM'
        AND PVP."ProjectType" = 'GITHUB'
)
SELECT
    PVP."Name", 
    PVP."Version"
FROM
    PVP
JOIN
    DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS AS P
ON
    PVP."ProjectType" = P."Type" 
    AND PVP."ProjectName" = P."Name"
ORDER BY 
    P."StarsCount" DESC
LIMIT 8;
