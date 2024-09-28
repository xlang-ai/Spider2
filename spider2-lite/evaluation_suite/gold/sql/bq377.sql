WITH json_files AS (
  SELECT
    c.id,
    JSON_EXTRACT(c.content, '$.require') AS dependencies
  FROM
    `bigquery-public-data.github_repos.contents` c
  JOIN (
    SELECT
      id
    FROM
      `bigquery-public-data.github_repos.files`
    WHERE
      path = 'composer.json'
  ) f
  ON
    c.id = f.id
),
package_names AS (
  SELECT
    TRIM(REGEXP_REPLACE(entry, r'^"|"$', '')) AS package_name
  FROM
    json_files,
    UNNEST(REGEXP_EXTRACT_ALL(CAST(dependencies AS STRING), r'"([^"]+)":')) AS entry
)
SELECT
  package_name,
  COUNT(*) AS count
FROM
  package_names
WHERE
  package_name IS NOT NULL
GROUP BY
  package_name
ORDER BY
  count DESC;
