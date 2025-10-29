WITH json_content AS (
  SELECT 
    "content",
    "sample_ref",
    "sample_path"
  FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS"
  WHERE "sample_path" ILIKE '%.json'
    AND "content" IS NOT NULL
    AND "content" != ''
),
parsed_json AS (
  SELECT 
    "sample_ref",
    "sample_path",
    TRY_PARSE_JSON("content") AS "parsed_content"
  FROM json_content
  WHERE TRY_PARSE_JSON("content") IS NOT NULL
),
require_sections AS (
  SELECT 
    "sample_ref",
    "sample_path",
    "parsed_content":"require" AS "require_obj"
  FROM parsed_json
  WHERE "parsed_content":"require" IS NOT NULL
),
flattened_packages AS (
  SELECT 
    r."sample_ref",
    r."sample_path",
    f.key::STRING AS "package_name"
  FROM require_sections r,
  LATERAL FLATTEN(input => r."require_obj") f
)
SELECT 
  "package_name",
  COUNT(*) AS "frequency"
FROM flattened_packages
WHERE "package_name" IS NOT NULL
GROUP BY "package_name"
ORDER BY "frequency" DESC, "package_name"