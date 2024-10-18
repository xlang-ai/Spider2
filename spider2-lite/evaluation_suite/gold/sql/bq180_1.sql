WITH extracted_modules AS (
  SELECT 
    file_id, 
    repo_name, 
    path, 
    line, 
    IF(
      ENDS_WITH(path, '.py'),
      'python',
      IF(ENDS_WITH(path, '.r'), 'r', NULL)
    ) AS language,
    IF(
      ENDS_WITH(path, '.py'),
      ARRAY_CONCAT(
        REGEXP_EXTRACT_ALL(line, r'\bimport\s+(\w+)'), 
        REGEXP_EXTRACT_ALL(line, r'\bfrom\s+(\w+)')
      ),
      IF(
        ENDS_WITH(path, '.r'),
        REGEXP_EXTRACT_ALL(line, r'library\s*\(\s*([^\s)]+)\s*\)'),
        []
      )
    ) AS modules
  FROM (
    SELECT
      ct.id AS file_id, 
      fl.repo_name, 
      path, 
      SPLIT(REPLACE(ct.content, "\n", " \n"), "\n") AS lines
    FROM `spider2-public-data.github_repos.sample_files` AS fl
    JOIN `spider2-public-data.github_repos.sample_contents` AS ct ON fl.id = ct.id
  ), UNNEST(lines) as line
  WHERE
    (ENDS_WITH(path, '.py') AND (REGEXP_CONTAINS(line, r'^import ') OR REGEXP_CONTAINS(line, r'^from '))) OR 
    (ENDS_WITH(path, '.r') AND REGEXP_CONTAINS(line, r'library\s*\('))
),
module_counts AS (
  SELECT 
    language,
    module,
    COUNT(*) AS occurrence_count
  FROM (
    SELECT 
      language,
      modules
    FROM extracted_modules
    WHERE modules IS NOT NULL
  ),UNNEST(modules) AS module
  GROUP BY language, module
),
top5_python AS (
  SELECT 
    'python' AS language,
    module,
    occurrence_count
  FROM module_counts
  WHERE language = 'python'
  ORDER BY occurrence_count DESC
),
top5_r AS (
  SELECT 
    'r' AS language,
    module,
    occurrence_count
  FROM module_counts
  WHERE language = 'r'
  ORDER BY occurrence_count DESC
)
SELECT * FROM top5_python
UNION ALL
SELECT * FROM top5_r
ORDER BY language, occurrence_count DESC;