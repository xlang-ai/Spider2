WITH
  python2_questions AS (
    SELECT
      q.id AS question_id,
      q.title,
      q.body AS question_body,
      q.tags
    FROM
      `bigquery-public-data.stackoverflow.posts_questions` q
    WHERE
      (LOWER(q.tags) LIKE '%python-2%'
      OR LOWER(q.tags) LIKE '%python-2.x%'
      OR (
        LOWER(q.title) LIKE '%python 2%'
        OR LOWER(q.body) LIKE '%python 2%'
        OR LOWER(q.title) LIKE '%python2%'
        OR LOWER(q.body) LIKE '%python2%'
      ))
      AND (
        LOWER(q.title) NOT LIKE '%python 3%'
        AND LOWER(q.body) NOT LIKE '%python 3%'
        AND LOWER(q.title) NOT LIKE '%python3%'
        AND LOWER(q.body) NOT LIKE '%python3%'
      )
  )

SELECT
  COUNT(*) AS count_number
FROM
  python2_questions q
LEFT JOIN
  `bigquery-public-data.stackoverflow.posts_answers` a
ON
  q.question_id = a.parent_id
GROUP BY q.question_id
ORDER BY count_number DESC
LIMIT 1

