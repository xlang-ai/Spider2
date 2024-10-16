WITH watched_repos AS (
    SELECT
        repo.name AS repo
    FROM 
        `githubarchive.month.2017*`
    WHERE
        type = "WatchEvent"
),
repo_watch_counts AS (
    SELECT
        repo,
        COUNT(*) AS watch_count
    FROM
        watched_repos
    GROUP BY
        repo
)

SELECT
    r.repo,
    r.watch_count
FROM
    `spider2-public-data.github_repos.sample_files` AS f
JOIN
    `spider2-public-data.github_repos.sample_contents` AS c
ON
    f.id = c.id
JOIN 
    repo_watch_counts AS r
ON
    f.repo_name = r.repo
WHERE
    f.path LIKE '%.py' 
    AND c.size < 15000 
    AND REGEXP_CONTAINS(c.content, r'def ')
GROUP BY
    r.repo, r.watch_count
ORDER BY
    r.watch_count DESC
LIMIT 
    3;