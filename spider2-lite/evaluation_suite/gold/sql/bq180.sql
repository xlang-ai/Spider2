SELECT module, COUNT(*) as occurrence_count
FROM (
  SELECT 
    file_id, 
    repo_name, 
    path, 
    line, 
    ARRAY_CONCAT(
      IF(
        ENDS_WITH(path, '.py'),
        ARRAY_CONCAT(
          REGEXP_EXTRACT_ALL(line, r'\bimport\s+(\w+)'), 
          REGEXP_EXTRACT_ALL(line, r'\bfrom\s+(\w+)')
        ),
        []
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
UNNEST(modules) as module
GROUP BY module
ORDER BY occurrence_count DESC
LIMIT 5
