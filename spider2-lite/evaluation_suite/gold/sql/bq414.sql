SELECT 
  a.object_id,
  a.title,
  FORMAT_TIMESTAMP('%Y-%m-%d', a.metadata_date) AS formatted_metadata_date
FROM `bigquery-public-data.the_met.objects` a
JOIN (
  SELECT object_id,
         cropHints.confidence AS cropConfidence
  FROM `bigquery-public-data.the_met.vision_api_data`, 
       UNNEST(cropHintsAnnotation.cropHints) cropHints
) b
ON a.object_id = b.object_id
WHERE a.department = "The Libraries"
AND b.cropConfidence > 0.5
AND a.title LIKE "%book%"