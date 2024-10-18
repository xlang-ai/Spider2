WITH content_extracted AS (
    SELECT 
        D.id AS id,
        repo_name,
        path,
        SPLIT(content, '\n') AS lines
    FROM 
        (
            SELECT 
                id,
                content
            FROM 
                `spider2-public-data.github_repos.sample_contents`
        ) AS D
    INNER JOIN 
        (
            SELECT 
                id,
                C.repo_name AS repo_name,
                path
            FROM 
                (
                    SELECT 
                        id,
                        repo_name,
                        path
                    FROM 
                        `spider2-public-data.github_repos.sample_files`
                    WHERE 
                        LOWER(path) LIKE '%readme.md'
                ) AS C
            INNER JOIN 
                (
                    SELECT 
                        repo_name,
                        language_struct.name AS language_name
                    FROM 
                        (
                            SELECT 
                                repo_name, 
                                language
                            FROM 
                                `spider2-public-data.github_repos.languages`
                        )
                    CROSS JOIN 
                        UNNEST(language) AS language_struct
                    WHERE 
                        LOWER(language_struct.name) LIKE '%python%'
                ) AS F
            ON 
                C.repo_name = F.repo_name
        ) AS E
    ON 
        E.id = D.id
),
non_empty_lines AS (
    SELECT 
        line
    FROM 
        content_extracted,
        UNNEST(lines) AS line
    WHERE 
        TRIM(line) != ''
        AND NOT STARTS_WITH(TRIM(line), '#')
        AND NOT STARTS_WITH(TRIM(line), '//')
),
line_frequencies AS (
    SELECT 
        line,
        COUNT(*) AS frequency
    FROM 
        non_empty_lines
    GROUP BY 
        line
    ORDER BY 
        frequency DESC
)
SELECT 
    line
FROM 
    line_frequencies
LIMIT 5;