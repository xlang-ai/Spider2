WITH model_scores AS (
    SELECT 
        DISTINCT name, 
        version, 
        step
    FROM 
        model_score
),
combined AS (
    SELECT 
        C.L1_model
    FROM 
        model_scores A
    INNER JOIN model C ON A.name = C.name AND A.version = C.version
),
frequency AS (
    SELECT 
        L1_model, 
        COUNT(*) AS cnt
    FROM 
        combined 
    GROUP BY 
        L1_model
),
max_frequency AS (
    SELECT 
        MAX(cnt) AS max_cnt
    FROM 
        frequency
)
SELECT
    f.L1_model,
    max_cnt
FROM 
    frequency f
INNER JOIN max_frequency m ON f.cnt = m.max_cnt;