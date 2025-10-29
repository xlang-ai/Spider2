
SELECT f."repo_name" AS repository_name
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
ON c."id" = f."id"
WHERE c."sample_path" ILIKE '%.swift' AND c."binary" = FALSE
ORDER BY c."copies" DESC NULLS LAST
LIMIT 1;
