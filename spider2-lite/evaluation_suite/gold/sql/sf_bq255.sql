SELECT
  COUNT(commits_table."message") AS "num_messages"
FROM (
  SELECT
    L."repo_name",
    language_struct.value:"name"::STRING AS "language_name"
  FROM
    GITHUB_REPOS.GITHUB_REPOS.LANGUAGES AS L,
    LATERAL FLATTEN(input => L."language") AS language_struct
) AS lang_table
JOIN 
  GITHUB_REPOS.GITHUB_REPOS.LICENSES AS license_table
ON 
  license_table."repo_name" = lang_table."repo_name"
JOIN (
  SELECT
    *
  FROM
    GITHUB_REPOS.GITHUB_REPOS.SAMPLE_COMMITS
) AS commits_table
ON 
  commits_table."repo_name" = lang_table."repo_name"
WHERE
  license_table."license" LIKE 'apache-2.0'
  AND lang_table."language_name" LIKE 'Shell'
  AND LENGTH(commits_table."message") > 5
  AND LENGTH(commits_table."message") < 10000
  AND LOWER(commits_table."message") NOT LIKE 'update%'
  AND LOWER(commits_table."message") NOT LIKE 'test%'
  AND LOWER(commits_table."message") NOT LIKE 'merge%';
