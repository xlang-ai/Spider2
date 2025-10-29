SELECT 
    w."repo":name::VARCHAR as repo_name,
    COUNT(*) as watch_count
FROM "GITHUB_REPOS_DATE"."YEAR"."_2017" w
WHERE w."type" = 'WatchEvent'
AND w."repo" IS NOT NULL
AND EXISTS (
    SELECT 1 
    FROM "GITHUB_REPOS_DATE"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
    WHERE c."sample_repo_name" = w."repo":name::VARCHAR
    AND c."sample_path" LIKE '%.py'
    AND c."size" < 15000
    AND c."content" LIKE '%def %'
)
GROUP BY repo_name
ORDER BY watch_count DESC
LIMIT 3;