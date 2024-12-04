WITH allowed_repos AS (
    SELECT 
        "repo_name",
        "license"
    FROM 
        GITHUB_REPOS_DATE.GITHUB_REPOS.LICENSES
    WHERE 
        "license" IN (
            'gpl-3.0', 'artistic-2.0', 'isc', 'cc0-1.0', 'epl-1.0', 'gpl-2.0',
            'mpl-2.0', 'lgpl-2.1', 'bsd-2-clause', 'apache-2.0', 'mit', 'lgpl-3.0'
        )
),
watch_counts AS (
    SELECT 
        TRY_PARSE_JSON("repo"):"name"::STRING AS "repo",
        COUNT(DISTINCT TRY_PARSE_JSON("actor"):"login"::STRING) AS "watches"
    FROM 
        GITHUB_REPOS_DATE.MONTH._202204
    WHERE 
        "type" = 'WatchEvent'
    GROUP BY 
        TRY_PARSE_JSON("repo"):"name"
),
issue_counts AS (
    SELECT 
        TRY_PARSE_JSON("repo"):"name"::STRING AS "repo",
        COUNT(*) AS "issue_events"
    FROM 
        GITHUB_REPOS_DATE.MONTH._202204
    WHERE 
        "type" = 'IssuesEvent'
    GROUP BY 
        TRY_PARSE_JSON("repo"):"name"
),
fork_counts AS (
    SELECT 
        TRY_PARSE_JSON("repo"):"name"::STRING AS "repo",
        COUNT(*) AS "forks"
    FROM 
        GITHUB_REPOS_DATE.MONTH._202204
    WHERE 
        "type" = 'ForkEvent'
    GROUP BY 
        TRY_PARSE_JSON("repo"):"name"
)
SELECT 
    ar."repo_name"
FROM 
    allowed_repos AS ar
INNER JOIN 
    fork_counts AS fc ON ar."repo_name" = fc."repo"
INNER JOIN 
    issue_counts AS ic ON ar."repo_name" = ic."repo"
INNER JOIN 
    watch_counts AS wc ON ar."repo_name" = wc."repo"
ORDER BY 
    (fc."forks" + ic."issue_events" + wc."watches") DESC
LIMIT 1;
