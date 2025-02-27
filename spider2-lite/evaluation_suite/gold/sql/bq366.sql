SELECT period, description, c FROM (
  SELECT 
a.period, 
b.description, 
count(*) c, 
row_number() over (partition by period order by count(*) desc) seqnum 
  FROM `bigquery-public-data.the_met.objects` a
  JOIN (
    SELECT 
        label.description as description, 
        object_id 
    FROM `bigquery-public-data.the_met.vision_api_data`, UNNEST(labelAnnotations) label
  ) b
  ON a.object_id = b.object_id
  WHERE a.period is not null
  group by 1,2
)
WHERE seqnum <= 3
AND c >= 500 # only include labels that have 50 or more pieces associated with it
ORDER BY period, c desc;