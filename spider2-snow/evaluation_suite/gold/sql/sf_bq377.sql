WITH json_files AS (
  SELECT
    c."id",
    TRY_PARSE_JSON(c."content"):"require" AS "dependencies"
  FROM
    GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
),
package_names AS (
  SELECT
    f.key AS "package_name"
  FROM
    json_files,
    LATERAL FLATTEN(input => "dependencies") AS f
)
SELECT
  "package_name",
  COUNT(*) AS "count"
FROM
  package_names
WHERE
  "package_name" IS NOT NULL
GROUP BY
  "package_name"
ORDER BY
  "count" DESC;
