-- Answer: proportion of README.md files (in non-Python repositories) whose contents include "Copyright (c)"
-- 1) Filter SAMPLE_CONTENTS to files whose path contains "readme.md" (case-insensitive).
-- 2) Exclude any repository that uses a language whose name contains the substring "python" (case-insensitive).
--    To detect such repositories, FLATTEN the VARIANT array "language" and look at the "name" field.
-- 3) Compute the proportion = (# files with the phrase) / (total # README.md files) as a floating value.

SELECT
    /* numerator: files whose content contains the phrase */
    COUNT_IF(LOWER(sc."content") LIKE '%copyright (c)%')::DOUBLE
    /
    /* denominator: total README.md files in non-Python repos */
    NULLIF(COUNT(*), 0)                                       AS "proportion"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc
WHERE LOWER(sc."sample_path") LIKE '%readme.md%'
  AND NOT EXISTS (
        SELECT 1
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES" l,
             LATERAL FLATTEN(input => l."language") f
        WHERE l."repo_name" = sc."sample_repo_name"
          AND LOWER(f.value:"name"::string) LIKE '%python%'
  );