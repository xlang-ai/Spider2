WITH BASE AS (
    SELECT 
        COL."case_id" AS "case_id",
        COL."motorcyclist_killed_count" AS "motorcyclist_killed_count",
        CASE WHEN PARTY."party_safety_equipment_1" = 'driver, motorcycle helmet used' THEN 1
             WHEN PARTY."party_safety_equipment_2" = 'driver, motorcycle helmet used' THEN 1
             WHEN PARTY."party_safety_equipment_1" = 'passenger, motorcycle helmet used' THEN 1
             WHEN PARTY."party_safety_equipment_2" = 'passenger, motorcycle helmet used' THEN 1
             ELSE 0 END AS "helmet_used",
        CASE WHEN PARTY."party_safety_equipment_1" = 'driver, motorcycle helmet not used' THEN 1
             WHEN PARTY."party_safety_equipment_2" = 'driver, motorcycle helmet not used' THEN 1
             WHEN PARTY."party_safety_equipment_1" = 'passenger, motorcycle helmet not used' THEN 1
             WHEN PARTY."party_safety_equipment_2" = 'passenger, motorcycle helmet not used' THEN 1
             ELSE 0 END AS "helmet_not_used"
    FROM CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.COLLISIONS COL
    JOIN CALIFORNIA_TRAFFIC_COLLISION.CALIFORNIA_TRAFFIC_COLLISION.PARTIES PARTY
        ON COL."case_id" = PARTY."case_id"
    WHERE 
        COL."motorcycle_collision" = '1'
        AND PARTY."party_age" IS NOT NULL
    GROUP BY 1, 2, PARTY."party_safety_equipment_1", PARTY."party_safety_equipment_2"
)
SELECT 
    ROUND(SUM(CASE WHEN "helmet_used" = 1 THEN "motorcyclist_killed_count" ELSE 0 END) * 100.0 / NULLIF(COUNT(CASE WHEN "helmet_used" = 1 THEN "case_id" END), 0), 2) AS "percent_killed_helmet_used",
    ROUND(SUM(CASE WHEN "helmet_not_used" = 1 THEN "motorcyclist_killed_count" ELSE 0 END) * 100.0 / NULLIF(COUNT(CASE WHEN "helmet_not_used" = 1 THEN "case_id" END), 0), 2) AS "percent_killed_helmet_not_used"
FROM 
    BASE