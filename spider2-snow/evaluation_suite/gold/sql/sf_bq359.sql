WITH js_flattened AS (
  SELECT
    "repo_name",
    f.value:"name"::STRING AS "lang",
    TRY_CAST(f.value:"bytes"::STRING AS NUMBER) AS "bytes"
  FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES,
       LATERAL FLATTEN(INPUT => "language") f
),
primary_lang AS (
  SELECT
    "repo_name",
    "lang",
    "bytes",
    ROW_NUMBER() OVER (
      PARTITION BY "repo_name"
      ORDER BY "bytes" DESC NULLS LAST, "lang" ASC
    ) AS "rn"
  FROM js_flattened
),
js_primary_repos AS (
  SELECT
    "repo_name"
  FROM primary_lang
  WHERE "rn" = 1
    AND LOWER("lang") = 'javascript'
),
commits_agg AS (
  SELECT
    "repo_name",
    COUNT(DISTINCT "commit") AS "commit_count"
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS
  WHERE "repo_name" IS NOT NULL
  GROUP BY "repo_name"
)
SELECT
  j."repo_name" AS "repo_name",
  c."commit_count" AS "commit_count"
FROM js_primary_repos j
JOIN commits_agg c
  ON j."repo_name" = c."repo_name"
ORDER BY
  c."commit_count" DESC NULLS LAST,
  j."repo_name" ASC
LIMIT 2;