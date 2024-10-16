SELECT
  COUNT(commits_table.message) AS num_messages
FROM (
  SELECT
    repo_name,
    lang.name AS language_name
  FROM
    `spider2-public-data.github_repos.languages` AS lang_table,
    UNNEST(LANGUAGE) AS lang) lang_table
JOIN
  `spider2-public-data.github_repos.licenses` AS license_table
ON
  license_table.repo_name = lang_table.repo_name
JOIN (
  SELECT
    *
  FROM
    `spider2-public-data.github_repos.sample_commits`) commits_table
ON
  commits_table.repo_name = lang_table.repo_name
WHERE
    (license_table.license LIKE 'apache-2.0')
  AND (lang_table.language_name LIKE 'Shell')
AND
  LENGTH(commits_table.message) > 5
AND 
  LENGTH(commits_table.message) < 10000
AND LOWER(commits_table.message) NOT LIKE 'update%'
AND LOWER(commits_table.message) NOT LIKE 'test%'
AND LOWER(commits_table.message) NOT LIKE 'merge%';