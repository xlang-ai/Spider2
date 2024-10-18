WITH imports AS (
  SELECT
    id,
    SPLIT(REGEXP_EXTRACT(content, r'import\s*\(([^)]*)\)'), '\n') AS lines
  FROM
    `spider2-public-data.github_repos.sample_contents`
  WHERE
    REGEXP_CONTAINS(content, r'import\s*\([^)]*\)')
),
go_files AS (
  SELECT
    id
  FROM
    `spider2-public-data.github_repos.sample_files`
  WHERE
    path LIKE '%.go'
  GROUP BY
    id
),
filtered_imports AS (
  SELECT
    id,
    line
  FROM
    imports, UNNEST(lines) AS line
),
joined_data AS (
  SELECT
    fi.line
  FROM
    filtered_imports fi
  JOIN
    go_files gf
  ON
    fi.id = gf.id
)
SELECT
  REGEXP_EXTRACT(line, r'"([^"]+)"') AS package
FROM
  joined_data
GROUP BY
  package
HAVING
  package IS NOT NULL
ORDER BY
  COUNT(*) DESC
LIMIT
  1;