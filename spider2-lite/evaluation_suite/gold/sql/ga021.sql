-- Define the date range and calculate the minimum date for filtering results
WITH dates AS (
    SELECT 
        DATE('2018-07-02') AS start_date,
        DATE('2018-07-16') AS end_date
),
-- Create a table of active dates for each user within the specified date range
dates_active_table AS (
    SELECT
        user_pseudo_id,
        PARSE_DATE('%Y%m%d', `event_date`) AS user_active_date
    FROM 
        `firebase-public-project.analytics_153293282.events_*` 
    WHERE 
        event_name = 'session_start'
        AND PARSE_DATE('%Y%m%d', `event_date`) BETWEEN (SELECT start_date FROM dates) AND (SELECT end_date FROM dates)
    GROUP BY 
        user_pseudo_id, user_active_date
),
-- Create a table of the earliest quickplay event date for each user within the specified date range
event_table AS (
    SELECT 
        user_pseudo_id,
        event_name,
        MIN(PARSE_DATE('%Y%m%d', `event_date`)) AS event_cohort_date
    FROM 
        `firebase-public-project.analytics_153293282.events_*` 
    WHERE 
        event_name IN ('level_start_quickplay', 'level_end_quickplay', 'level_complete_quickplay', 
                       'level_fail_quickplay', 'level_reset_quickplay', 'level_retry_quickplay')
        AND PARSE_DATE('%Y%m%d', `event_date`) BETWEEN (SELECT start_date FROM dates) AND (SELECT end_date FROM dates)
    GROUP BY 
        user_pseudo_id, event_name
),
-- Calculate the number of days since each user's initial quickplay event
days_since_event_table AS (
    SELECT
        events.user_pseudo_id,
        events.event_name AS event_cohort,
        events.event_cohort_date,
        days.user_active_date,
        DATE_DIFF(days.user_active_date, events.event_cohort_date, DAY) AS days_since_event
    FROM 
        event_table events
    LEFT JOIN 
        dates_active_table days ON events.user_pseudo_id = days.user_pseudo_id
    WHERE 
        events.event_cohort_date <= days.user_active_date
),
-- Calculate the weeks since each user's initial quickplay event and count the active days in each week
weeks_retention AS (
    SELECT
        event_cohort,
        user_pseudo_id,
        CAST(CASE WHEN days_since_event = 0 THEN 0 ELSE CEIL(days_since_event / 7) END AS INTEGER) AS weeks_since_event,
        COUNT(DISTINCT days_since_event) AS days_active_since_event -- Count Days Active in Week
    FROM 
        days_since_event_table
    GROUP BY 
        event_cohort, user_pseudo_id, weeks_since_event
),
-- Aggregate the weekly retention data
aggregated_weekly_retention_table AS (
    SELECT
        event_cohort,
        weeks_since_event,
        SUM(days_active_since_event) AS weekly_days_active,
        COUNT(DISTINCT user_pseudo_id) AS retained_users
    FROM 
        weeks_retention
    GROUP BY 
        event_cohort, weeks_since_event
),
RETENTION_INFO AS (
SELECT
    event_cohort,
    weeks_since_event,
    weekly_days_active,
    retained_users,
    (retained_users / MAX(retained_users) OVER (PARTITION BY event_cohort)) AS retention_rate
FROM 
    aggregated_weekly_retention_table
ORDER BY 
    event_cohort, weeks_since_event
)

SELECT event_cohort, retention_rate
FROM
RETENTION_INFO
WHERE weeks_since_event = 2