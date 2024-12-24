WITH extracted_modules AS (
SELECT 
    el."file_id" AS "file_id", 
    el."repo_name", 
    el."path" AS "path_", 
    REPLACE(line.value, '"', '') AS "line_",
    CASE
        WHEN ENDSWITH(el."path", '.py') THEN 'python'
        WHEN ENDSWITH(el."path", '.r') THEN 'r'
        ELSE NULL
    END AS "language",
    CASE
        WHEN ENDSWITH(el."path", '.py') THEN
            ARRAY_CAT(
                ARRAY_CONSTRUCT(REGEXP_SUBSTR(line.value, '\\bimport\\s+(\\w+)', 1, 1, 'e')),
                ARRAY_CONSTRUCT(REGEXP_SUBSTR(line.value, '\\bfrom\\s+(\\w+)', 1, 1, 'e'))
            )
        WHEN ENDSWITH(el."path", '.r') THEN
            ARRAY_CONSTRUCT(REGEXP_SUBSTR(line.value, 'library\\s*\\(\\s*([^\\s)]+)\\s*\\)', 1, 1, 'e'))
        ELSE ARRAY_CONSTRUCT()
    END AS "modules"
FROM (
    SELECT
        ct."id" AS "file_id", 
        fl."repo_name" AS "repo_name", 
        fl."path", 
        SPLIT(REPLACE(ct."content", '\n', ' \n'), '\n') AS "lines"
    FROM 
        GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_FILES AS fl
    JOIN 
        GITHUB_REPOS_DATE.GITHUB_REPOS.SAMPLE_CONTENTS AS ct 
        ON fl."id" = ct."id"
) AS el,
LATERAL FLATTEN(input => el."lines") AS line 
WHERE
    (
        ENDSWITH("path_", '.py') 
        AND 
        (
            "line_" LIKE 'import %' 
            OR 
            "line_" LIKE 'from %'
        )
    )
    OR
    (
        ENDSWITH("path_", '.r') 
        AND 
        "line_" LIKE 'library%('
    )

),
module_counts AS (
    SELECT 
        em."language",
        f.value::STRING AS "module",
        COUNT(*) AS "occurrence_count"
    FROM 
        extracted_modules AS em,
        LATERAL FLATTEN(input => em."modules") AS f
    WHERE 
        em."modules" IS NOT NULL
        AND f.value IS NOT NULL
    GROUP BY 
        em."language", 
        f.value
),
python AS (
    SELECT 
        "language",
        "module",
        "occurrence_count"
    FROM 
        module_counts
    WHERE 
        "language" = 'python'
),
rlanguage AS (
    SELECT 
        "language",
        "module",
        "occurrence_count"
    FROM 
        module_counts AS mc_inner
    WHERE 
        "language" = 'r'
)
SELECT 
    *
FROM 
    python
UNION ALL
SELECT 
    *
FROM 
    rlanguage
ORDER BY 
    "language", 
    "occurrence_count" DESC;