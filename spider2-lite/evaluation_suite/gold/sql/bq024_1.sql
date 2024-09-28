SELECT
    state_code,
    evaluation_group,
    state_name,
    SUM(macroplot_acres) + SUM(subplot_acres) AS total_acres,
FROM (
    SELECT
        state_code,
        evaluation_group,
        state_name,
        macroplot_acres,
        subplot_acres,
        MAX(evaluation_group) OVER (PARTITION BY state_code) AS latest                   
    FROM `bigquery-public-data.usfs_fia.estimated_timberland_acres`
)
WHERE evaluation_group = latest
GROUP BY state_code, state_name, evaluation_group
ORDER BY total_acres
LIMIT 10;