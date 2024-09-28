WITH UserUpvotes AS (
  SELECT
    Users.UserName,
    COUNT(DISTINCT ForumMessageVotes.Id) AS UpvotesReceived
  FROM spider2-public-data.meta_kaggle.ForumMessageVotes AS ForumMessageVotes
  INNER JOIN spider2-public-data.meta_kaggle.Users AS Users
    ON Users.Id = ForumMessageVotes.ToUserId
  GROUP BY Users.UserName
),
UserGivenUpvotes AS (
  SELECT
    Users.UserName,
    COUNT(DISTINCT ForumMessageVotes.Id) AS UpvotesGiven
  FROM spider2-public-data.meta_kaggle.ForumMessageVotes AS ForumMessageVotes
  INNER JOIN spider2-public-data.meta_kaggle.Users AS Users
    ON Users.Id = ForumMessageVotes.FromUserId
  GROUP BY Users.UserName
),
MostUpvotedUser AS (
  SELECT
    COALESCE(up.UserName, ug.UserName) AS UserName,
    COALESCE(up.UpvotesReceived, 0) AS UpvotesReceived,
    COALESCE(ug.UpvotesGiven, 0) AS UpvotesGiven
  FROM UserUpvotes AS up
  FULL OUTER JOIN UserGivenUpvotes AS ug
    ON up.UserName = ug.UserName
)
SELECT 
  UserName AS MostUpvotedUserName,
  UpvotesReceived,
  UpvotesGiven
FROM MostUpvotedUser
ORDER BY UpvotesReceived DESC
LIMIT 3;