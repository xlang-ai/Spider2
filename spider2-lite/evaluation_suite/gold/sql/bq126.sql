SELECT
  o.artist_display_name,
  o.title,
  o.object_end_date,
  o.medium,
  i.original_image_url
FROM (
  SELECT
    object_id,
    title,
    artist_display_name,
    object_end_date,
    medium
  FROM
    `bigquery-public-data.the_met.objects`
  WHERE
    department = "Photographs"
    AND object_name LIKE "%Photograph%"
    AND artist_display_name != "Unknown"
    AND object_end_date <= 1839
) o
INNER JOIN (
  SELECT
    original_image_url,
    object_id
  FROM
    `bigquery-public-data.the_met.images`
) i
ON
  o.object_id = i.object_id
ORDER BY
  o.object_end_date
;