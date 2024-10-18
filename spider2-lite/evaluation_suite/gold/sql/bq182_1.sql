SELECT COUNT(*) AS total_pull_requests
FROM (
  SELECT
    a.type AS type,
    b.language AS lang,
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
      language
    FROM (
      SELECT
        repo_name,
        language
      FROM (
        SELECT repo_name, language.name AS language, language.bytes
        FROM `spider2-public-data.github_repos.languages`,
        UNNEST(language) AS language
      )
    )
    WHERE language = 'JavaScript'
    GROUP BY repo_name, language
  ) b
  ON a.name = b.name
)
WHERE type = 'PullRequestEvent';