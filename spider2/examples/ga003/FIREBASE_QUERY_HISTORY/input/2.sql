--- grab those events along with the actual value of the value parameter

SELECT event_name, param.value.int_value AS score
FROM `firebase-public-project.analytics_153293282.events_20180915`,
UNNEST(event_params) AS param
WHERE event_name = "level_complete_quickplay"
AND param.key = "value"