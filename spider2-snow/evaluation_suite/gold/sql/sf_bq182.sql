WITH
  event_data AS (
    SELECT
      "type",
      EXTRACT(YEAR FROM TO_TIMESTAMP("created_at" / 1000000)) AS "year",
      EXTRACT(QUARTER FROM TO_TIMESTAMP("created_at" / 1000000)) AS "quarter",
      REGEXP_REPLACE(
        "repo"::variant:"url"::string,
        'https:\\/\\/github\\.com\\/|https:\\/\\/api\\.github\\.com\\/repos\\/',
        ''
      ) AS "name"
    FROM GITHUB_REPOS_DATE.DAY._20230118
  ),

  repo_languages AS (
    SELECT
      "repo_name" AS "name",
      "lang"
    FROM (
      SELECT
        "repo_name",
        FIRST_VALUE("language") OVER (
          PARTITION BY "repo_name" ORDER BY "bytes" DESC
        ) AS "lang"
      FROM (
        SELECT
          "repo_name",
          "language".value:"name" AS "language",
          "language".value:"bytes" AS "bytes"
        FROM GITHUB_REPOS_DATE.GITHUB_REPOS.LANGUAGES,
        LATERAL FLATTEN(INPUT => "language") AS "language"
      )
    )
    WHERE "lang" IS NOT NULL
    GROUP BY "repo_name", "lang"
  ),

  joined_data AS (
    SELECT
      a."type" AS "type",
      b."lang" AS "language",
      a."year" AS "year",
      a."quarter" AS "quarter"
    FROM event_data a
    JOIN repo_languages b
      ON a."name" = b."name"
  ),

  count_data AS (
    SELECT
      "language",
      "year",
      "quarter",
      "type",
      COUNT(*) AS "count"
    FROM joined_data
    GROUP BY "type", "language", "year", "quarter"
    ORDER BY "year", "quarter", "count" DESC
  )

SELECT
  REPLACE("language", '"', '') AS "language_name",
  "count"
FROM count_data
WHERE "count" >= 5
  AND "type" = 'PullRequestEvent';
