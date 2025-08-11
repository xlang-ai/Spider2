WITH selected_repos AS (
  SELECT
    f."id",
    f."repo_name" AS "repo_name",
    f."path" AS "path"
  FROM
    GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES AS f
),
deduped_files AS (
  SELECT
    f."id",
    MIN(f."repo_name") AS "repo_name",
    MIN(f."path") AS "path"
  FROM
    selected_repos AS f
  GROUP BY
    f."id"
)
SELECT
  f."repo_name"
FROM
  deduped_files AS f
  JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS AS c 
  ON f."id" = c."id"
WHERE
  NOT c."binary"
  AND f."path" LIKE '%.swift'
ORDER BY c."copies" DESC
LIMIT 1;
