WITH repos as (
  SELECT b.repo_with_watches as repo_name,
         b.watches as watches
  FROM (
    SELECT DISTINCT repo_name AS repo_in_mirror
    FROM `spider2-public-data.github_repos.sample_files` 
  ) a RIGHT JOIN (
    SELECT repo.name AS repo_with_watches, APPROX_COUNT_DISTINCT(actor.id) watches 
    FROM `githubarchive.year.2017` 
    WHERE type='WatchEvent'
    GROUP BY 1 
    HAVING watches > 300
  ) b
  ON a.repo_in_mirror = b.repo_with_watches
  WHERE
    a.repo_in_mirror IS NOT NULL
),
contents as (
  SELECT *
  FROM (
    SELECT DISTINCT *
    FROM `spider2-public-data.github_repos.sample_files` 
    WHERE repo_name IN (SELECT repo_name FROM repos)
  ) a RIGHT JOIN (
    SELECT id as idcontent,
           content as content
    FROM `spider2-public-data.github_repos.sample_contents` 
  ) b
  ON a.id = b.idcontent 
)
SELECT repos.repo_name,
       repos.watches
FROM repos
JOIN
  contents
ON
  repos.repo_name = contents.repo_name 
ORDER BY
  repos.watches DESC
LIMIT 5