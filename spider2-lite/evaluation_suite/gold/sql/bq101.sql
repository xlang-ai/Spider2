SELECT
  package,
  COUNT(*) count
FROM (
  SELECT
    REGEXP_EXTRACT(line, r' ([a-z0-9\._]*)\.') AS package,
    id
  FROM (
    SELECT
      SPLIT(content, '\n') AS lines,
      id
    FROM
      `spider2-public-data.github_repos.sample_contents`
    WHERE
      REGEXP_CONTAINS(content, r'import')
      AND sample_path LIKE '%.java'
  ), UNNEST(lines) AS line
  WHERE
    LEFT(line, 6) = 'import'
  GROUP BY
    package,
    id
)
GROUP BY
  package
ORDER BY
  count DESC
LIMIT
  10;