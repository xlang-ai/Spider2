WITH base AS (
    SELECT 
        col.case_id AS case_id,
        col.motorcyclist_killed_count AS motorcyclist_killed_count,
        CASE WHEN party.party_safety_equipment_1 = 'driver, motorcycle helmet used' THEN 1
             WHEN party.party_safety_equipment_2 = 'driver, motorcycle helmet used' THEN 1
             WHEN party.party_safety_equipment_1 = 'passenger, motorcycle helmet used' THEN 1
             WHEN party.party_safety_equipment_2 = 'passenger, motorcycle helmet used' THEN 1
             ELSE 0 END AS helmet_used,
        CASE WHEN party.party_safety_equipment_1 = 'driver, motorcycle helmet not used' THEN 1
             WHEN party.party_safety_equipment_2 = 'driver, motorcycle helmet not used' THEN 1
             WHEN party.party_safety_equipment_1 = 'passenger, motorcycle helmet not used' THEN 1
             WHEN party.party_safety_equipment_2 = 'passenger, motorcycle helmet not used' THEN 1
             ELSE 0 END AS helmet_not_used
    FROM collisions col
    JOIN parties party
        ON col.case_id = party.case_id
    WHERE 
        col.motorcycle_collision = 1
        AND party.party_age IS NOT NULL
    GROUP BY 1, 2
)
SELECT 
    ROUND(SUM(CASE WHEN helmet_used = 1 THEN motorcyclist_killed_count ELSE 0 END) * 100.0 / NULLIF(COUNT(CASE WHEN helmet_used = 1 THEN case_id END), 0), 2) AS percent_killed_helmet_used,
    ROUND(SUM(CASE WHEN helmet_not_used = 1 THEN motorcyclist_killed_count ELSE 0 END) * 100.0 / NULLIF(COUNT(CASE WHEN helmet_not_used = 1 THEN case_id END), 0), 2) AS percent_killed_helmet_not_used
FROM 
    base