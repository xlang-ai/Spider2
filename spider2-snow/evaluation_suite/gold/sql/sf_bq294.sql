SELECT
  t."trip_id" AS "trip_id",
  t."duration_sec" AS "duration_sec",
  TO_TIMESTAMP_NTZ(t."start_date" / 1000000) AS "start_date",
  t."start_station_name" AS "start_station_name",
  (t."start_station_name" || ' - ' || t."end_station_name") AS "route",
  t."bike_number" AS "bike_number",
  t."subscriber_type" AS "subscriber_type",
  CAST(t."member_birth_year" AS INT) AS "member_birth_year",
  (EXTRACT(YEAR FROM CURRENT_DATE) - CAST(t."member_birth_year" AS INT)) AS "age",
  CASE
    WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - CAST(t."member_birth_year" AS INT)) < 40 THEN 'Young (<40 Y.O)'
    WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - CAST(t."member_birth_year" AS INT)) BETWEEN 40 AND 60 THEN 'Adult (40-60 Y.O)'
    ELSE 'Senior Adult (>60 Y.O)'
  END AS "age_class",
  t."member_gender" AS "member_gender",
  r."name" AS "region_name"
FROM "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_TRIPS" t
LEFT JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_STATION_INFO" si
  ON si."station_id" = CAST(t."start_station_id" AS VARCHAR)
LEFT JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_REGIONS" r
  ON r."region_id" = si."region_id"
WHERE
  t."start_station_name" IS NOT NULL AND TRIM(t."start_station_name") != ''
  AND t."member_birth_year" IS NOT NULL
  AND t."member_gender" IS NOT NULL AND TRIM(t."member_gender") != ''
  AND TO_TIMESTAMP_NTZ(t."start_date" / 1000000) BETWEEN TO_TIMESTAMP_NTZ('2017-07-01 00:00:00') AND TO_TIMESTAMP_NTZ('2017-12-31 23:59:59')
ORDER BY t."duration_sec" DESC
LIMIT 5;