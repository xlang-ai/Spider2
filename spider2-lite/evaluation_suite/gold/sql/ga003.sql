WITH EventData AS (
    SELECT 
        user_pseudo_id, 
        event_timestamp, 
        param
    FROM 
        `firebase-public-project.analytics_153293282.events_20180915`,
        UNNEST(event_params) AS param
    WHERE 
        event_name = "level_complete_quickplay"
        AND (param.key = "value" OR param.key = "board")
),
ProcessedData AS (
    SELECT 
        user_pseudo_id, 
        event_timestamp, 
        MAX(IF(param.key = "value", param.value.int_value, NULL)) AS score,
        MAX(IF(param.key = "board", param.value.string_value, NULL)) AS board_type
    FROM 
        EventData
    GROUP BY 
        user_pseudo_id, 
        event_timestamp
)
SELECT 
    ANY_VALUE(board_type) AS board, 
    AVG(score) AS average_score
FROM 
    ProcessedData
GROUP BY 
    board_type
