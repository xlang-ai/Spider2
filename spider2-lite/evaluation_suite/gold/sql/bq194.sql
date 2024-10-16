WITH extracted_modules AS (
  SELECT
    file_id, repo_name, path, line,
    IF(
      ENDS_WITH(path, '.py'),
      'Python',
      IF(
        (
          ENDS_WITH(path, '.r') OR
          ENDS_WITH(path, '.R') OR
          ENDS_WITH(path, '.Rmd') OR
          ENDS_WITH(path, '.rmd')
        ),
        'R',
        IF(
          ENDS_WITH(path, '.ipynb'),
          'IPython',
          'Others'
        )
      )
    ) AS script_type,
    IF(
      ENDS_WITH(path, '.py'),
      IF(
        REGEXP_CONTAINS(line, r'^\s*import\s+'),
        REGEXP_EXTRACT_ALL(line, r'(?:^\s*import\s|,)\s*([a-zA-Z0-9\_\.]+)'),
        REGEXP_EXTRACT_ALL(line, r'^\s*from\s+([a-zA-Z0-9\_\.]+)')
      ),
      IF(
        (
          ENDS_WITH(path, '.r') OR
          ENDS_WITH(path, '.R') OR
          ENDS_WITH(path, '.Rmd') OR
          ENDS_WITH(path, '.rmd')
        ),
        REGEXP_EXTRACT_ALL(line, r'library\s*\((?:package=|)[\"\']*([a-zA-Z0-9\_\.]+)[\"\']*.*?\)'), -- we're still ignoring commented out imports
        IF(
          ENDS_WITH(path, '.ipynb'),
          IF(
            REGEXP_CONTAINS(line, r'"\s*import\s+'),
            REGEXP_EXTRACT_ALL(line, r'(?:"\s*import\s|,)\s*([a-zA-Z0-9\_\.]+)'),
            REGEXP_EXTRACT_ALL(line, r'"\s*from\s+([a-zA-Z0-9\_\.]+)')
          ),
          ['']
        )
      )
    ) AS modules
  FROM (
    SELECT
      ct.id AS file_id, repo_name, path,
      # Add a space after each line.
      # It is required to ensure correct line numbering.
      SPLIT(REPLACE(content, "\n", " \n"), "\n") AS lines
    FROM `spider2-public-data.github_repos.sample_files` AS fl
    JOIN `spider2-public-data.github_repos.sample_contents` AS ct ON fl.id = ct.id
    WHERE
      ENDS_WITH(path, '.py') OR
      (
        ENDS_WITH(path, '.r') OR
        ENDS_WITH(path, '.R') OR
        ENDS_WITH(path, '.Rmd') OR
        ENDS_WITH(path, '.rmd')
      ) OR
      ENDS_WITH(path, '.ipynb')
  ), UNNEST(lines) AS line
  WHERE
    (ENDS_WITH(path, '.py') AND (REGEXP_CONTAINS(line, r'^\s*import\s+') OR REGEXP_CONTAINS(line, r'^\s*from .* import '))) OR
    (
      (
        ENDS_WITH(path, '.r') OR
        ENDS_WITH(path, '.R') OR
        ENDS_WITH(path, '.Rmd') OR
        ENDS_WITH(path, '.rmd')
      ) AND REGEXP_CONTAINS(line, r'library\s*\(')
    ) OR
    (
      ENDS_WITH(path, '.ipynb') AND
      (
        REGEXP_CONTAINS(line, r'"\s*import\s+') OR
        REGEXP_CONTAINS(line, r'"\s*from .* import ')
      )
    )
), unnested_modules AS (
  SELECT
    file_id, repo_name, path, script_type, module
  FROM extracted_modules,
  UNNEST(modules) AS module
), module_frequencies AS (
  SELECT
    module,
    script_type,
    COUNT(*) AS frequency
  FROM unnested_modules
  GROUP BY module, script_type
  ORDER BY frequency DESC
)

SELECT
  module
FROM module_frequencies
ORDER BY frequency DESC
LIMIT 1
OFFSET 1;