WITH avg_loss_tb AS (
    SELECT 
        AVG([Loss_Rate_%]) AS avg_loss_rate,
        COUNT([index]) AS total_num 
    FROM 
        veg_loss_rate_df
    WHERE 
        [loss_rate_%] <> ''
), 
std AS (
    SELECT 
        ROUND(SQRT(SUM(POWER(([Loss_Rate_%] - (SELECT avg_loss_rate FROM avg_loss_tb)), 2)) / alt.total_num), 2) AS std
    FROM 
        veg_loss_rate_df lrd, avg_loss_tb alt
)
SELECT
    AVG([Loss_Rate_%]) AS 'avg_loss_rate_%',
    SUM(
        CASE
            WHEN [Loss_Rate_%] BETWEEN (SELECT avg_loss_rate FROM avg_loss_tb) - (SELECT std FROM std) AND (SELECT avg_loss_rate FROM avg_loss_tb) + (SELECT std FROM std) THEN 1
            ELSE 0
        END
    ) AS items_within_stdev,
    SUM(
        CASE
            WHEN [Loss_Rate_%] > ((SELECT avg_loss_rate FROM avg_loss_tb) + (SELECT std FROM std)) THEN 1
            ELSE 0
        END
    ) AS above_stdev,
    SUM(
        CASE
            WHEN [Loss_Rate_%] < ((SELECT avg_loss_rate FROM avg_loss_tb) - (SELECT std FROM std)) THEN 1
            ELSE 0
        END
    ) AS items_below_stdev
FROM 
    veg_loss_rate_df;
