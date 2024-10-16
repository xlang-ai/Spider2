DECLARE
    Sys STRING DEFAULT 'NPM';

WITH HighestReleases AS (
    SELECT
        Name,
        Version,
    FROM (
        SELECT
            Name,
            Version,
            ROW_NUMBER() OVER (
                PARTITION BY Name
                ORDER BY VersionInfo.Ordinal DESC
            ) AS RowNumber
        FROM
            `spider2-public-data.deps_dev_v1.PackageVersions`
        WHERE
            System = Sys
            AND VersionInfo.IsRelease)
    WHERE RowNumber = 1
),

TopDependencies AS (
    SELECT
        D.Name,
        D.Version,
        COUNT(*) AS NDependencies
    FROM
        `spider2-public-data.deps_dev_v1.Dependencies` AS D
    JOIN
        HighestReleases AS H
    ON
        D.Name = H.Name AND D.Version = H.Version
    WHERE
        D.System = Sys
    GROUP BY
        Name,
        Version
    ORDER BY
        NDependencies DESC
    LIMIT 100
)

SELECT
    lnk.URL
FROM 
    `spider2-public-data.deps_dev_v1.PackageVersions` AS P,
    unnest(Links) as lnk
JOIN 
    TopDependencies AS T
ON
    T.Name = P.Name AND T.Version = P.Version
WHERE
    P.System = Sys
    AND P.Name NOT LIKE '%@%'
    AND lnk.Label = 'SOURCE_REPO'
    AND lower(lnk.URL) LIKE '%github.com%'
ORDER BY T.NDependencies DESC
LIMIT 1;