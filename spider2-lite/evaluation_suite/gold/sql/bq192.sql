WITH allowed_repos AS (
    SELECT 
        repo_name, 
        license 
    FROM 
        `spider2-public-data.github_repos.licenses`
    WHERE 
        license IN UNNEST(["artistic-2.0", "isc", "mit", "apache-2.0"])
),
watch_counts AS (
    SELECT 
        repo.name AS repo,
        COUNT(DISTINCT actor.login) AS watches
    FROM 
        `githubarchive.month.202204`
    WHERE 
        type = "WatchEvent"
    GROUP BY 
        repo
),
issue_counts AS (
    SELECT 
        repo.name AS repo,
        COUNT(*) AS issue_events
    FROM 
        `githubarchive.month.202204`
    WHERE 
        type = 'IssuesEvent'
    GROUP BY 
        repo
),
fork_counts AS (
    SELECT 
        repo.name AS repo,
        COUNT(*) AS forks
    FROM 
        `githubarchive.month.202204`
    WHERE 
        type = 'ForkEvent'
    GROUP BY 
        repo
),
metadata AS (
    SELECT 
        repo_name, 
        license, 
        forks, 
        issue_events, 
        watches
    FROM 
        allowed_repos
    INNER JOIN 
        fork_counts 
    ON 
        repo_name = fork_counts.repo
    INNER JOIN 
        issue_counts 
    ON 
        repo_name = issue_counts.repo
    INNER JOIN 
        watch_counts 
    ON 
        repo_name = watch_counts.repo
),
github_files_at_head AS (
    SELECT 
        repo_name
    FROM 
        `spider2-public-data.github_repos.sample_files`
    WHERE 
        ref = "refs/heads/master" 
        AND ENDS_WITH(path, ".py")
        AND symlink_target IS NULL
    GROUP BY 
        repo_name
)
SELECT 
    metadata.repo_name AS repository
FROM 
    metadata
INNER JOIN 
    github_files_at_head
ON 
    metadata.repo_name = github_files_at_head.repo_name
ORDER BY 
    (metadata.forks + metadata.issue_events + metadata.watches) DESC
LIMIT 1;