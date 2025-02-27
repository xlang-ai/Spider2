with page_visit_sequence AS (
    SELECT
        fullVisitorID,
        visitID,
        pagePath,
        LEAD(timestamp, 1) OVER (PARTITION BY fullVisitorId, visitID order by timestamp) - timestamp AS page_duration,
        LEAD(pagePath, 1) OVER (PARTITION BY fullVisitorId, visitID order by timestamp) AS next_page,
        RANK() OVER (PARTITION BY fullVisitorId, visitID order by timestamp) AS step_number
    FROM (
        SELECT
            pages.fullVisitorID,
            pages.visitID,
            pages.pagePath,
            visitors.campaign,
            MIN(pages.timestamp) timestamp
        FROM (
            SELECT
                fullVisitorId,
                visitId,
                trafficSource.campaign campaign
            FROM
                `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
                UNNEST(hits) as hits
            WHERE
                _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
                AND hits.type='PAGE'
                AND REGEXP_CONTAINS(hits.page.pagePath, r'^/home')
                AND REGEXP_CONTAINS(trafficSource.campaign, r'Data Share')
        ) AS visitors
        JOIN(
            SELECT
                fullVisitorId,
                visitId,
                visitStartTime + hits.time / 1000 AS timestamp,
                hits.page.pagePath AS pagePath
            FROM
                `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
                UNNEST(hits) as hits
            WHERE
                _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
        ) as pages
        ON
            visitors.fullVisitorID = pages.fullVisitorID
            AND visitors.visitID = pages.visitID
        GROUP BY 
            pages.fullVisitorID, visitors.campaign, pages.visitID, pages.pagePath
        ORDER BY 
            pages.fullVisitorID, pages.visitID, timestamp
    )
    ORDER BY fullVisitorId, visitID, step_number
),
most_common_next_page AS (
    SELECT
        next_page,
        COUNT(next_page) as page_count
    FROM page_visit_sequence
    WHERE
        next_page IS NOT NULL
        AND REGEXP_CONTAINS(pagePath, r'^/home')
    GROUP BY next_page
    ORDER BY page_count DESC
    LIMIT 1
),
max_page_duration AS (
    SELECT MAX(page_duration) as max_duration
    FROM page_visit_sequence
    WHERE
        page_duration IS NOT NULL
        AND REGEXP_CONTAINS(pagePath, r'^/home')
)
SELECT
    next_page,
    max_duration
FROM
    most_common_next_page,
    max_page_duration;
