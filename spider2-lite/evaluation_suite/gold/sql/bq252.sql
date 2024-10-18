WITH selected_repos as (
  SELECT
    f.id,
    f.repo_name as repo_name,
    f.path as path,
  FROM
    `spider2-public-data.github_repos.sample_files` as f
),

deduped_files as (
  SELECT
    f.id,
    MIN(f.repo_name) as repo_name,
    MIN(f.path) as path,
  FROM
    selected_repos as f
  GROUP BY
    f.id
)

SELECT
  f.repo_name,
FROM
  deduped_files as f
  JOIN `spider2-public-data.github_repos.sample_contents` as c on f.id = c.id
WHERE
  NOT c.binary
  AND f.path like '%.swift'
ORDER BY c.copies DESC
LIMIT 1;