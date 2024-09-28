WITH AverageScoreCTE AS (
    SELECT 
        AVG(RealScore.Score) AS AvgScore
    FROM 
        `spider2-public-data.meta_kaggle.ForumTopics` AS ForumTopics
    INNER JOIN `spider2-public-data.meta_kaggle.ForumMessages` AS ForumMessages
        ON ForumMessages.Id = ForumTopics.FirstForumMessageId
    INNER JOIN (
        SELECT 
            ForumMessageId,
            COUNT(DISTINCT FromUserId) AS Score
        FROM 
            `spider2-public-data.meta_kaggle.ForumMessageVotes`
        GROUP BY ForumMessageId
    ) AS RealScore
        ON RealScore.ForumMessageId = ForumTopics.FirstForumMessageId
),
UserScoresCTE AS (
    SELECT 
        Users.UserName,
        RealScore.Score,
        ABS(RealScore.Score - AverageScoreCTE.AvgScore) AS ScoreDifference
    FROM 
        `spider2-public-data.meta_kaggle.ForumTopics` AS ForumTopics
    INNER JOIN `spider2-public-data.meta_kaggle.ForumMessages` AS ForumMessages
        ON ForumMessages.Id = ForumTopics.FirstForumMessageId
    INNER JOIN `spider2-public-data.meta_kaggle.Users` AS Users
        ON Users.Id = ForumMessages.PostUserId
    INNER JOIN (
        SELECT 
            ForumMessageId,
            COUNT(DISTINCT FromUserId) AS Score
        FROM 
            `spider2-public-data.meta_kaggle.ForumMessageVotes`
        GROUP BY ForumMessageId
    ) AS RealScore
        ON RealScore.ForumMessageId = ForumTopics.FirstForumMessageId,
    AverageScoreCTE
)
SELECT 
    UserName,
    ScoreDifference
FROM 
    UserScoresCTE
ORDER BY 
    Score DESC
LIMIT 3;