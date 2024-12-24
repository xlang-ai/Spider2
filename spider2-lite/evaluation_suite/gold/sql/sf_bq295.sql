WITH watched_repos AS (
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201701
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201702
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201703
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201704
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201705
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201706
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201707
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201708
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201709
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201710
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201711
    WHERE
        "type" = 'WatchEvent'
    UNION ALL
    SELECT
        PARSE_JSON("repo"):"name"::STRING AS "repo"
    FROM 
        GITHUB_REPOS_DATE.MONTH._201712
    WHERE
        "type" = 'WatchEvent'
),

repo_watch_counts AS (
    SELECT
        "repo",
        COUNT(*) AS "watch_count"
    FROM
        watched_repos
    GROUP BY
        "repo"
)

SELECT
    REPLACE(r."repo", '"', '') AS "repo",
    r."watch_count"
FROM
    GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_FILES AS f
JOIN
    GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_CONTENTS AS c
    ON f."id" = c."id"
JOIN 
    repo_watch_counts AS r
    ON f."repo_name" = r."repo"
WHERE
    f."path" LIKE '%.py' 
    AND c."size" < 15000 
    AND POSITION('def ' IN c."content") > 0
GROUP BY
    r."repo", r."watch_count"
ORDER BY
    r."watch_count" DESC
LIMIT 
    3;
