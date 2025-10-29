SELECT
    q."package_name",
    q."version",
    q."github_stars"
FROM (
    WITH latest_release AS (
        SELECT
            pv."Name",
            pv."Version"
        FROM "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONS" pv
        WHERE pv."System" = 'NPM'
          AND pv."Name" NOT LIKE '%>%'
          AND COALESCE((pv."VersionInfo":"IsRelease")::BOOLEAN, FALSE)
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY pv."Name"
            ORDER BY COALESCE(pv."UpstreamPublishedAt", pv."SnapshotAt") DESC, pv."Version" DESC
        ) = 1
    ),
    latest_project AS (
        SELECT
            pr."Name" AS "ProjectName",
            pr."StarsCount"
        FROM "DEPS_DEV_V1"."DEPS_DEV_V1"."PROJECTS" pr
        WHERE pr."Type" = 'GITHUB'
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY pr."Name"
            ORDER BY pr."SnapshotAt" DESC
        ) = 1
    ),
    package_project AS (
        SELECT DISTINCT
            pvtp."Name",
            pvtp."Version",
            pvtp."ProjectName"
        FROM "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONTOPROJECT" pvtp
        WHERE pvtp."System" = 'NPM'
          AND pvtp."ProjectType" = 'GITHUB'
          AND pvtp."RelationType" = 'SOURCE_REPO_TYPE'
    )
    SELECT
        lr."Name" AS "package_name",
        lr."Version" AS "version",
        lp."StarsCount" AS "github_stars",
        ROW_NUMBER() OVER (
            PARTITION BY lr."Name"
            ORDER BY lp."StarsCount" DESC, mp."ProjectName"
        ) AS rn
    FROM latest_release lr
    JOIN package_project mp
      ON mp."Name" = lr."Name"
     AND mp."Version" = lr."Version"
    JOIN latest_project lp
      ON lp."ProjectName" = mp."ProjectName"
) q
WHERE q.rn = 1
ORDER BY q."github_stars" DESC, q."package_name"
LIMIT 8