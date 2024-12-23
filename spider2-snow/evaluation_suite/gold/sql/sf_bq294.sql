SELECT
  "trip_id",
  "duration_sec",
  DATE(TO_TIMESTAMP_LTZ("start_date" / 1000000)) AS "star_date", -- 将微秒转换为日期
  "start_station_name",
  CONCAT("start_station_name", ' - ', "end_station_name") AS "route",
  "bike_number",
  "subscriber_type",
  "member_birth_year",
  (EXTRACT(YEAR FROM CURRENT_DATE()) - "member_birth_year") AS "age",
  CASE
    WHEN (EXTRACT(YEAR FROM CURRENT_DATE()) - "member_birth_year") < 40 THEN 'Young (<40 Y.O)'
    WHEN (EXTRACT(YEAR FROM CURRENT_DATE()) - "member_birth_year") BETWEEN 40 AND 60 THEN 'Adult (40-60 Y.O)'
    ELSE 'Senior Adult (>60 Y.O)'
  END AS "age_class",
  "member_gender",
  c."name" AS "region_name"
FROM "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_TRIPS" a
LEFT JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_STATION_INFO" b 
  ON a."start_station_name" = b."name"
LEFT JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_REGIONS" c 
  ON b."region_id" = c."region_id"
WHERE TO_TIMESTAMP_LTZ("start_date" / 1000000) BETWEEN '2017-07-01' AND '2017-12-31'
  AND b."name" IS NOT NULL
  AND "member_birth_year" IS NOT NULL
  AND "member_gender" IS NOT NULL
ORDER BY "duration_sec" DESC
LIMIT 5;
