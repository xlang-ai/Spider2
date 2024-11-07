--- show the level_complete_quickplay event for 2018-09-15
SELECT *
FROM `firebase-public-project.analytics_153293282.events_20180915`
WHERE event_name = "level_complete_quickplay"
LIMIT 10