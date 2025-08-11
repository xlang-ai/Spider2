WITH repositories AS (
    SELECT
        t2."repo_name",
        t2."language"
    FROM (
        SELECT
            t1."repo_name",
            t1."language",
            RANK() OVER (PARTITION BY t1."repo_name" ORDER BY t1."language_bytes" DESC) AS "rank"
        FROM (
            SELECT
                l."repo_name",
                lang.value:"name"::STRING AS "language",
                lang.value:"bytes"::NUMBER AS "language_bytes"
            FROM
                GITHUB_REPOS.GITHUB_REPOS.LANGUAGES AS l,
                LATERAL FLATTEN(input => l."language") AS lang
        ) AS t1
    ) AS t2
    WHERE t2."rank" = 1
),
python_repo AS (
    SELECT
        "repo_name",
        "language"
    FROM
        repositories
    WHERE
        "language" = 'JavaScript'
)
SELECT 
    sc."repo_name", 
    COUNT(sc."commit") AS "num_commits"
FROM 
    GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS AS sc
INNER JOIN 
    python_repo 
ON 
    python_repo."repo_name" = sc."repo_name"
GROUP BY 
    sc."repo_name"
ORDER BY 
    "num_commits" DESC
LIMIT 2;
