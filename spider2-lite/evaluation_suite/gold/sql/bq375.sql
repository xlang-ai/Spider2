WITH files_with_levels AS (
  SELECT
    files.path AS path,
    LENGTH(files.path) - LENGTH(REPLACE(files.path, '/', '')) AS dir_level,
    CASE
      WHEN REGEXP_CONTAINS(files.path, r'\.py$') THEN 'Python'
      WHEN REGEXP_CONTAINS(files.path, r'\.c$') THEN 'C'
      WHEN REGEXP_CONTAINS(files.path, r'\.ipynb$') THEN 'Jupyter Notebook'
      WHEN REGEXP_CONTAINS(files.path, r'\.java$') THEN 'Java'
      WHEN REGEXP_CONTAINS(files.path, r'\.js$') THEN 'JavaScript'
      ELSE 'Other'
    END AS file_type
  FROM
    `spider2-public-data.github_repos.sample_files` AS files
  WHERE
    REGEXP_CONTAINS(files.path, r'\.py$') OR
    REGEXP_CONTAINS(files.path, r'\.c$') OR
    REGEXP_CONTAINS(files.path, r'\.ipynb$') OR
    REGEXP_CONTAINS(files.path, r'\.java$') OR
    REGEXP_CONTAINS(files.path, r'\.js$')
)
SELECT
  file_type,
  COUNT(*) AS file_count
FROM
  files_with_levels
WHERE
  dir_level > 10
GROUP BY
  file_type
ORDER BY
  file_count DESC
LIMIT 1;