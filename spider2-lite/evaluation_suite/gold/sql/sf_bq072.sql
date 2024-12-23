WITH BlackRace AS (
    SELECT CAST("Code" AS INT) AS CODE
    FROM DEATH.DEATH.RACE
    WHERE LOWER("Description") LIKE '%black%'
)
SELECT 
    v."Age", 
    v."Total" AS "Vehicle_Total", 
    v."Black" AS "Vehicle_Black",
    g."Total" AS "Gun_Total", 
    g."Black" AS "Gun_Black"
FROM (
    SELECT 
        "Age", 
        COUNT(*) AS "Total", 
        COUNT_IF("Race" IN (SELECT CODE FROM BlackRace)) AS "Black"
    FROM DEATH.DEATH.DEATHRECORDS d
    JOIN (
        SELECT 
            DISTINCT e."DeathRecordId" AS "id"
        FROM DEATH.DEATH.ENTITYAXISCONDITIONS e
        JOIN (
            SELECT * 
            FROM DEATH.DEATH.ICD10CODE 
            WHERE LOWER("Description") LIKE '%vehicle%'
        ) c 
        ON e."Icd10Code" = c."Code"
    ) f
    ON d."Id" = f."id"
    WHERE "Age" BETWEEN 12 AND 18
    GROUP BY "Age"
) v  -- Vehicle

JOIN (
    SELECT 
        "Age", 
        COUNT(*) AS "Total", 
        COUNT_IF("Race" IN (SELECT CODE FROM BlackRace)) AS "Black"
    FROM DEATH.DEATH.DEATHRECORDS d
    JOIN (
        SELECT 
            DISTINCT e."DeathRecordId" AS "id"
        FROM DEATH.DEATH.ENTITYAXISCONDITIONS e
        JOIN (
            SELECT 
                "Code", "Description" 
            FROM DEATH.DEATH.ICD10CODE
            WHERE "Description" LIKE '%firearm%'
        ) c 
        ON e."Icd10Code" = c."Code"
    ) f
    ON d."Id" = f."id"
    WHERE "Age" BETWEEN 12 AND 18
    GROUP BY "Age"
) g
ON g."Age" = v."Age";
