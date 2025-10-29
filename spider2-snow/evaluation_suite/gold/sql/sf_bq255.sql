SELECT
    COUNT(*) AS "commit_count"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_COMMITS" AS "sc"
INNER JOIN (
    SELECT DISTINCT "l"."repo_name"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" AS "l",
         LATERAL FLATTEN(INPUT => "l"."language") AS "lang"
    WHERE LOWER("lang"."VALUE":"name"::STRING) = 'shell'
) AS "shell_repos"
    ON "sc"."repo_name" = "shell_repos"."repo_name"
INNER JOIN (
    SELECT DISTINCT "repo_name"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."LICENSES"
    WHERE LOWER("license") = 'apache-2.0'
) AS "licensed_repos"
    ON "sc"."repo_name" = "licensed_repos"."repo_name"
WHERE "sc"."message" IS NOT NULL
  AND LENGTH("sc"."message") > 5
  AND LENGTH("sc"."message") < 10000
  AND NOT REGEXP_LIKE(LOWER(LTRIM("sc"."message")), '^(merge|update|test)\b');