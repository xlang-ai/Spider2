WITH first_answers AS (
  SELECT
    parent_id AS question_id,
    MIN(creation_date) AS first_answer_date
  FROM
    `bigquery-public-data.stackoverflow.posts_answers`
  GROUP BY
    parent_id
)

SELECT
  FORMAT_DATE('%A', DATE(q.creation_date)) AS question_day,
  SUM(CASE WHEN f.first_answer_date IS NOT NULL AND TIMESTAMP_DIFF(f.first_answer_date, q.creation_date, MINUTE) <= 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS percent_questions
FROM
  `bigquery-public-data.stackoverflow.posts_questions` q
LEFT JOIN
  first_answers f
ON
  q.id = f.question_id
GROUP BY
  question_day
ORDER BY
  percent_questions DESC
LIMIT 1 OFFSET 2