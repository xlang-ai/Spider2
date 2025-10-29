WITH "events" AS (
    SELECT
        "session",
        "stamp",
        "path",
        "search_type"
    FROM "LOG"."LOG"."ACTIVITY_LOG"
),

"first_target" AS (
    SELECT
        "session",
        "path",
        "search_type",
        "stamp"      AS "target_stamp"
    FROM (
        SELECT
            "session",
            "path",
            "search_type",
            "stamp",
            ROW_NUMBER() OVER (PARTITION BY "session" ORDER BY "stamp") AS "rn"
        FROM "events"
        WHERE "path" ILIKE '%/detail%' OR "path" ILIKE '%/complete%'
    ) t
    WHERE "rn" = 1
),

"pre_counts" AS (
    SELECT
        ft."session",
        ft."path"          AS "target_path",
        ft."search_type"   AS "target_search_type",
        COUNT(e.*) AS "pre_event_count"
    FROM "first_target" ft
    LEFT JOIN "events" e      /* LEFT JOIN so zero counts are kept */
      ON  e."session" = ft."session"
      AND e."stamp"   < ft."target_stamp"               -- strictly before
      AND e."search_type" IS NOT NULL
      AND e."search_type" <> ''
    GROUP BY ft."session", ft."path", ft."search_type"
),

"min_count" AS (
    SELECT MIN("pre_event_count") AS "min_cnt" FROM "pre_counts"
)

SELECT
    p."session",
    p."target_path"  AS "path",
    p."target_search_type" AS "search_type"
FROM "pre_counts" p
JOIN "min_count"  m  ON p."pre_event_count" = m."min_cnt"
ORDER BY p."session";