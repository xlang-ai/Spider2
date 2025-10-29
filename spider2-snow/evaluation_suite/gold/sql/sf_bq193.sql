WITH readme_lines AS (
  SELECT
    sc."sample_repo_name" AS "repo_name",
    TRIM(REPLACE(l.value::string, '\r', '')) AS "line_clean"
  FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc,
       LATERAL FLATTEN(input => SPLIT(sc."content", '\n')) l
  WHERE sc."sample_path" ILIKE '%README.md'
    AND NVL(sc."binary", FALSE) = FALSE
    AND sc."content" IS NOT NULL
),
filtered_lines AS (
  SELECT
    rl."repo_name",
    rl."line_clean"
  FROM readme_lines rl
  WHERE rl."line_clean" != ''
    AND LTRIM(rl."line_clean") NOT LIKE '#%'
    AND LTRIM(rl."line_clean") NOT LIKE '//%'
),
repo_languages AS (
  SELECT
    lg."repo_name",
    TRIM(fl.value:"name"::string) AS "language_name"
  FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" lg,
       LATERAL FLATTEN(input => lg."language") fl
  WHERE fl.value:"name" IS NOT NULL
    AND TRIM(fl.value:"name"::string) != ''
)
SELECT
  f."line_clean" AS "line",
  COUNT(DISTINCT f."repo_name") AS "frequency",
  LISTAGG(DISTINCT rl."language_name", ', ') WITHIN GROUP (ORDER BY rl."language_name") AS "languages"
FROM filtered_lines f
LEFT JOIN repo_languages rl
  ON rl."repo_name" = f."repo_name"
GROUP BY f."line_clean"
ORDER BY "frequency" DESC, "line" ASC