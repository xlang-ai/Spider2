WITH
-- Get recent data
RecentData AS (
    SELECT
        FORMAT_TIMESTAMP('%Y%m', creation_date) AS month_index,
        tags
    FROM
        `bigquery-public-data.stackoverflow.posts_questions`
    WHERE
        EXTRACT(YEAR FROM DATE(creation_date)) = 2022
),

-- Monthly number of questions posted
MonthlyQuestions AS (
    SELECT
        month_index,
        COUNT(*) AS num_questions
    FROM
        RecentData
    GROUP BY
        month_index
),

-- Monthly number of questions posted with specific tags
TaggedQuestions AS (
    SELECT
        month_index,
        tag,
        COUNT(*) AS num_tags
    FROM
        RecentData,
        UNNEST(SPLIT(tags, '|')) AS tag
    WHERE
        tag IN ('python')
    GROUP BY
        month_index, tag
)

SELECT
    a.month_index,
    a.num_tags / b.num_questions AS proportion
FROM
    TaggedQuestions a
LEFT JOIN
    MonthlyQuestions b ON a.month_index = b.month_index
ORDER BY
    a.month_index, proportion DESC;