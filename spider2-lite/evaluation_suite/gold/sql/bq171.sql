WITH UserStats2019 AS (
    SELECT 
        Users.UserName,
        COUNT(DISTINCT ForumMessageVotes.Id) AS Upvote
    FROM 
        `spider2-public-data.meta_kaggle.ForumMessageVotes` AS ForumMessageVotes
    INNER JOIN `spider2-public-data.meta_kaggle.Users` AS Users
        ON Users.Id = ForumMessageVotes.FromUserId
    WHERE 
        EXTRACT(YEAR FROM VoteDate) = 2019
    GROUP BY 
        Users.UserName
),
AverageUpvotes2019 AS (
    SELECT 
        AVG(Upvote) AS AvgUpvote2019
    FROM UserStats2019
),
UserClosestToAverage AS (
    SELECT 
        UserStats2019.UserName,
        ABS(UserStats2019.Upvote - AverageUpvotes2019.AvgUpvote2019) AS UpvoteDifference
    FROM 
        UserStats2019, AverageUpvotes2019
)
SELECT 
    UserName
FROM 
    UserClosestToAverage
ORDER BY 
    UpvoteDifference ASC,
    UserName ASC
LIMIT 1;