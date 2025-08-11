WITH badge_counts AS (
  SELECT
    c.id,
    COUNT(DISTINCT d.id) AS badge_number
  FROM
    `bigquery-public-data.stackoverflow.users` AS c
  JOIN
    `bigquery-public-data.stackoverflow.badges` AS d
  ON
    c.id = d.user_id
  GROUP BY
    c.id
),
labeled_questions AS (
  SELECT
    a.id,
    IF(
      a.id IN (
        SELECT DISTINCT b.id
        FROM
          `bigquery-public-data.stackoverflow.posts_answers` AS a
        JOIN
          `bigquery-public-data.stackoverflow.posts_questions` AS b
        ON
          a.parent_id = b.id
        WHERE
          b.accepted_answer_id IS NULL
          AND a.score / b.view_count > 0.01
      ) OR accepted_answer_id IS NOT NULL,
      1,
      0
    ) AS label,
    a.owner_user_id,
    LENGTH(a.body) AS body_length
  FROM
    `bigquery-public-data.stackoverflow.posts_questions` AS a
)
SELECT
  lq.id,
  b.reputation,
  b.up_votes - b.down_votes AS net_votes,
  e.badge_number
FROM
  labeled_questions AS lq
JOIN
  `bigquery-public-data.stackoverflow.users` AS b
ON
  lq.owner_user_id = b.id
JOIN
  badge_counts AS e
ON
  b.id = e.id
WHERE
  lq.label = 1
ORDER BY
  lq.body_length DESC
LIMIT
  10;


