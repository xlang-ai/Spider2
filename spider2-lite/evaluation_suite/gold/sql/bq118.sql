WITH WhiteRace AS (
    SELECT CAST(Code AS INT64)
    FROM `spider2-public-data.death.Race` 
    WHERE LOWER(Description) LIKE '%white%'
),
VehicleDeaths AS (
    SELECT 
        d.Age,
        SUM(CASE WHEN d.Race IN (SELECT * FROM WhiteRace) THEN 1 ELSE 0 END) AS Vehicle_White
    FROM `spider2-public-data.death.DeathRecords` d
    JOIN `spider2-public-data.death.EntityAxisConditions` e ON d.id = e.DeathRecordId
    JOIN `spider2-public-data.death.Icd10Code` c ON e.Icd10Code = c.code
    WHERE LOWER(c.Description) LIKE '%vehicle%'
    GROUP BY d.Age
),
GunDeaths AS (
    SELECT 
        d.Age,
        SUM(CASE WHEN d.Race IN (SELECT * FROM WhiteRace) THEN 1 ELSE 0 END) AS Gun_White
    FROM `spider2-public-data.death.DeathRecords` d
    JOIN `spider2-public-data.death.EntityAxisConditions` e ON d.id = e.DeathRecordId
    JOIN `spider2-public-data.death.Icd10Code` c ON e.Icd10Code = c.code
    WHERE LOWER(c.Description) LIKE '%discharge%'
      AND c.Description NOT IN (
          'Urethral discharge', 
          'Discharge of firework', 
          'Legal intervention involving firearm discharge'
      )
    GROUP BY d.Age
)
SELECT 
    (SELECT AVG(Gun_White) FROM GunDeaths) 
    - 
    (SELECT AVG(Vehicle_White) FROM VehicleDeaths)
