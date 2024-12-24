WITH content_extracted AS (
    SELECT 
        "D"."id" AS "id",
        "repo_name",
        "path",
        SPLIT("content", '\n') AS "lines",
        "language_name"
    FROM 
        (
            SELECT 
                "id",
                "content"
            FROM 
                "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS"
        ) AS "D"
    INNER JOIN 
        (
            SELECT 
                "id",
                "C"."repo_name" AS "repo_name",
                "path",
                "language_name"
            FROM 
                (
                    SELECT 
                        "id",
                        "repo_name",
                        "path"
                    FROM 
                        "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES"
                    WHERE 
                        LOWER("path") LIKE '%readme.md'
                ) AS "C"
            INNER JOIN 
                (
                    SELECT 
                        "repo_name",
                        "language_struct".value:"name" AS "language_name"
                    FROM 
                        (
                            SELECT 
                                "repo_name", 
                                "language"
                            FROM 
                                "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES"
                        )
                    CROSS JOIN 
                        LATERAL FLATTEN(INPUT => "language") AS "language_struct"
                ) AS "F"
            ON 
                "C"."repo_name" = "F"."repo_name"
        ) AS "E"
    ON 
        "E"."id" = "D"."id"
),
non_empty_lines AS (
    SELECT 
        "line".value AS "line_",
        "language_name"
    FROM 
        content_extracted,
        LATERAL FLATTEN(INPUT => "lines") AS "line"
    WHERE 
        TRIM("line".value) != ''
        AND NOT STARTSWITH(TRIM("line".value), '#')
        AND NOT STARTSWITH(TRIM("line".value), '//')
),
aggregated_languages AS (
    SELECT 
        "line_",
        COUNT(*) AS "frequency",
        ARRAY_AGG("language_name") AS "languages"
    FROM 
        non_empty_lines
    GROUP BY 
        "line_"
)

SELECT 
    REGEXP_REPLACE("line_", '^"|"$', '') AS "line",
    "frequency",
    ARRAY_TO_STRING(ARRAY_SORT("languages"), ', ') AS "languages_sorted"
FROM 
    aggregated_languages
ORDER BY 
    "frequency" DESC;

