WITH primary_languages AS (
    SELECT 
        "repo_name",
        lang_data.value:"name"::string as primary_language,
        ROW_NUMBER() OVER (PARTITION BY "repo_name" ORDER BY lang_data.value:"bytes"::int DESC) as rn
    FROM GITHUB_REPOS_DATE.GITHUB_REPOS.LANGUAGES,
         TABLE(FLATTEN(PARSE_JSON("language"))) as lang_data
    WHERE "language" != '[]'
),
primary_lang_only AS (
    SELECT "repo_name", primary_language
    FROM primary_languages
    WHERE rn = 1
),
pull_requests_jan18 AS (
    SELECT 
        "repo":"name"::string as repo_name,
        COUNT(*) as pr_count
    FROM GITHUB_REPOS_DATE.YEAR._2023 
    WHERE "type" = 'PullRequestEvent'
        AND "created_at" >= 1674009600000000  -- 2023-01-18 00:00:00 UTC
        AND "created_at" < 1674096000000000   -- 2023-01-19 00:00:00 UTC
    GROUP BY "repo":"name"::string
)
SELECT 
    plo.primary_language,
    SUM(pr.pr_count) as total_pr_events
FROM primary_lang_only plo
JOIN pull_requests_jan18 pr ON plo."repo_name" = pr.repo_name
GROUP BY plo.primary_language
HAVING total_pr_events >= 5
ORDER BY total_pr_events DESC