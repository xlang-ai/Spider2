SELECT language AS name, count
FROM (
  SELECT *
  FROM (
    SELECT
      lang AS language,
      y AS year,
      q AS quarter,
      type,
      COUNT(*) AS count
    FROM (
      SELECT
        a.type AS type,
        b.lang AS lang,
        a.y AS y,
        a.q AS q
      FROM (
        SELECT
          type,
          EXTRACT(YEAR FROM created_at) AS y,
          EXTRACT(QUARTER FROM created_at) AS q,
          REGEXP_REPLACE(
            repo.url,
            r'https:\/\/github\.com\/|https:\/\/api\.github\.com\/repos\/',
            ''
          ) AS name
        FROM `githubarchive.day.20230118`
      ) a
      JOIN (
        SELECT
          repo_name AS name,
          lang
        FROM (
          SELECT
            repo_name,
            FIRST_VALUE(language) OVER (
              PARTITION BY repo_name ORDER BY bytes DESC
            ) AS lang
          FROM (
            SELECT repo_name, language.name AS language, language.bytes
            FROM `spider2-public-data.github_repos.languages`,
            UNNEST(language) AS language
          )
        )
        WHERE lang IS NOT NULL
        GROUP BY repo_name, lang
      ) b
      ON a.name = b.name
    )
    GROUP BY type, language, year, quarter
    ORDER BY year, quarter, count DESC
  )
  WHERE count >= 100
)
WHERE type = 'PullRequestEvent';