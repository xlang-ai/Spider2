WITH allowed_repos as (
    select
        repo_name,
        license
    from `spider2-public-data.github_repos.licenses`
    where license in unnest(
      ["gpl-3.0", "artistic-2.0", "isc", "cc0-1.0", "epl-1.0", "gpl-2.0",
       "mpl-2.0", "lgpl-2.1", "bsd-2-clause", "apache-2.0", "mit", "lgpl-3.0"])
),
watch_counts as (
    SELECT 
        repo.name as repo,
        COUNT(DISTINCT actor.login) watches,
    FROM `githubarchive.month.202204`
    WHERE type = "WatchEvent"
    GROUP BY repo
),
issue_counts as (
    SELECT 
        repo.name as repo,
        COUNT(*) issue_events,
    FROM `githubarchive.month.202204`
    WHERE type = 'IssuesEvent'
    GROUP BY repo
),
fork_counts as (
    SELECT 
        repo.name as repo,
        COUNT(*) forks,
    FROM `githubarchive.month.202204`
    WHERE type = 'ForkEvent'
    GROUP BY repo
)
SELECT repo_name
FROM allowed_repos
INNER JOIN fork_counts ON repo_name = fork_counts.repo
INNER JOIN issue_counts on repo_name = issue_counts.repo
INNER JOIN watch_counts ON repo_name = watch_counts.repo
ORDER BY forks + issue_events + watches DESC
LIMIT 1;