WITH
  lines AS (
  SELECT
    SPLIT(content, '\\n') AS line,
    id
  FROM
    `spider2-public-data.github_repos.sample_contents`
  WHERE
    sample_path LIKE "%.sql" )
SELECT
  Indentation,
  COUNT(Indentation) AS number_of_occurence
FROM (
  SELECT
    CASE
        WHEN MIN(CHAR_LENGTH(REGEXP_EXTRACT(flatten_line, r"\s+$")))>=1 THEN 'trailing'
        WHEN MIN(CHAR_LENGTH(REGEXP_EXTRACT(flatten_line, r"^ +")))>=1 THEN 'Space'
        ELSE 'Other'
    END AS Indentation
  FROM
    lines
  CROSS JOIN
    UNNEST(lines.line) AS flatten_line
  GROUP BY
    id)
GROUP BY
  Indentation
ORDER BY
  number_of_occurence DESC