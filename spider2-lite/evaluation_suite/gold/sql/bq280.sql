WITH UserAnswers AS (
  SELECT
    owner_user_id AS answer_owner_id,
    COUNT(id) AS answer_count
  FROM bigquery-public-data.stackoverflow.posts_answers
  WHERE owner_user_id IS NOT NULL
  GROUP BY owner_user_id
),
DetailedUsers AS (
  SELECT
    id AS user_id,
    display_name AS user_display_name,
    reputation
  FROM bigquery-public-data.stackoverflow.users
  WHERE display_name IS NOT NULL AND reputation > 10
),
RankedUsers AS (
  SELECT
    u.user_display_name,
    u.reputation,
    a.answer_count,
    ROW_NUMBER() OVER (ORDER BY a.answer_count DESC) AS rank
  FROM DetailedUsers u
  JOIN UserAnswers a ON u.user_id = a.answer_owner_id
)
SELECT
  user_display_name,
FROM RankedUsers
WHERE rank = 1;
