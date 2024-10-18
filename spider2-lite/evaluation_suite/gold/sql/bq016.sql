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
            AND VersionInfo.IsRelease
    )
    WHERE RowNumber = 1
)

SELECT
    D.Dependency.Name,
    D.Dependency.Version
FROM
    `spider2-public-data.deps_dev_v1.Dependencies` AS D
JOIN
    HighestReleases AS H
USING
    (Name, Version)
WHERE
    D.System = Sys
GROUP BY
    D.Dependency.Name,
    D.Dependency.Version
ORDER BY
    COUNT(*) DESC
LIMIT 1;