SELECT
    t."trip_id",
    t."duration_sec",
    TO_DATE(TO_TIMESTAMP(t."start_date" / 1000000)) AS start_date,
    t."start_station_name",
    t."start_station_name" || ' - ' || t."end_station_name" AS route,
    t."bike_number",
    t."subscriber_type",
    t."member_birth_year",
    2025 - t."member_birth_year" AS age,
    CASE
        WHEN 2025 - t."member_birth_year" < 40 THEN 'Young (<40 Y.O)'
        WHEN 2025 - t."member_birth_year" BETWEEN 40 AND 60 THEN 'Adult (40-60 Y.O)'
        ELSE 'Senior (>60 Y.O)'
    END AS age_class,
    t."member_gender",
    r."name" AS region_name
FROM "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_TRIPS" t
JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_STATION_INFO" s
    ON CAST(t."start_station_id" AS TEXT) = s."station_id"
JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_REGIONS" r
    ON s."region_id" = r."region_id"
WHERE YEAR(TO_TIMESTAMP(t."start_date" / 1000000)) = 2017
    AND t."member_birth_year" IS NOT NULL
    AND t."member_gender" IS NOT NULL
    AND t."member_gender" != ''
ORDER BY t."duration_sec" DESC
LIMIT 5
