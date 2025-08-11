SELECT
  Day_of_Week,
  COUNT(1) AS Num_Questions,
  SUM(answered_in_1h) AS Num_Answered_in_1H,
  ROUND(100 * SUM(answered_in_1h) / COUNT(1),1) AS Percent_Answered_in_1H
FROM
(
  SELECT
    q.id AS question_id,
    EXTRACT(DAYOFWEEK FROM q.creation_date) AS day_of_week,
    MAX(IF(a.parent_id IS NOT NULL AND
           (UNIX_SECONDS(a.creation_date)-UNIX_SECONDS(q.creation_date))/(60*60) <= 1, 1, 0)) AS answered_in_1h
  FROM
    `bigquery-public-data.stackoverflow.posts_questions` q
  LEFT JOIN
    `bigquery-public-data.stackoverflow.posts_answers` a
  ON q.id = a.parent_id
  WHERE EXTRACT(YEAR FROM a.creation_date) = 2020
    AND EXTRACT(YEAR FROM q.creation_date) = 2020
  GROUP BY question_id, day_of_week
)
GROUP BY
  Day_of_Week
ORDER BY
  Day_of_Week;