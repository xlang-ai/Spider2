WITH LatestWeek AS (
    SELECT
        DATEADD(WEEK, -52, MAX("week")) AS "last_year_week"
    FROM
        GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS
),
LatestRefreshDate AS (
    SELECT
        MAX("refresh_date") AS "latest_refresh_date"
    FROM
        GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS
),
RankedTerms AS (
    SELECT
        "term",
        "week",
        CASE WHEN "score" IS NULL THEN NULL ELSE "dma_name" END AS "dma_name",
        "rank",
        "score",
        ROW_NUMBER() OVER (
            PARTITION BY "term", "week"
            ORDER BY "score" DESC
        ) AS rn
    FROM
        GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS
    WHERE
        "week" = (SELECT "last_year_week" FROM LatestWeek)
        AND "refresh_date" = (SELECT "latest_refresh_date" FROM LatestRefreshDate)
)

SELECT
    "term"
FROM
    RankedTerms
WHERE
    rn = 1
ORDER BY
    "rank"
LIMIT 1;
