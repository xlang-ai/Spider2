--- calculating the mean, getting some quantiles, and figuring out the standard deviation 

SELECT AVG(param.value.int_value) AS average, 
  APPROX_QUANTILES(param.value.int_value, 2) AS quantiles, 
  STDDEV(param.value.int_value) AS stddev
FROM `firebase-public-project.analytics_153293282.events_20180915`,
UNNEST(event_params) AS param
WHERE event_name = "level_complete_quickplay"
AND param.key = "value"