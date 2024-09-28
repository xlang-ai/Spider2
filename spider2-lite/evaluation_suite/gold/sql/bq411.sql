WITH cte AS (
    SELECT
        refresh_date,
        term,
        rank
    FROM
        bigquery-public-data.google_trends.top_terms
    WHERE
        rank IN (1, 2, 3)
        AND refresh_date BETWEEN '2024-09-01' AND '2024-09-14'
        AND EXTRACT(DAYOFWEEK FROM refresh_date) BETWEEN 2 AND 6
)
SELECT
    refresh_date AS Day,
    MAX(CASE WHEN rank = 1 THEN term END) AS top1_term,
    MAX(CASE WHEN rank = 2 THEN term END) AS top2_term,
    MAX(CASE WHEN rank = 3 THEN term END) AS top3_term
FROM
    cte
GROUP BY
    refresh_date
ORDER BY
    refresh_date DESC;
