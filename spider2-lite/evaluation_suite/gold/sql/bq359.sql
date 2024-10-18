WITH python_repo AS (
    WITH
        repositories AS (
        SELECT
        t2.repo_name,
        t2.LANGUAGE
        FROM (
        SELECT
            repo_name,
            LANGUAGE,
            RANK() OVER (PARTITION BY t1.repo_name ORDER BY t1.language_bytes DESC) AS rank
        FROM (
            SELECT
            repo_name,
            arr.name AS LANGUAGE,
            arr.bytes AS language_bytes
            FROM
            `spider2-public-data.github_repos.languages`,
            UNNEST(LANGUAGE) arr ) AS t1 ) AS t2
        WHERE
        rank = 1)
    SELECT
        repo_name,
        LANGUAGE
    FROM
        repositories
    WHERE
        LANGUAGE = 'JavaScript'
        )
SELECT sc.repo_name, COUNT(commit) AS num_commits FROM `spider2-public-data.github_repos.sample_commits` sc
INNER JOIN python_repo ON python_repo.repo_name = sc.repo_name
GROUP BY sc.repo_name
ORDER BY num_commits 
DESC LIMIT 2