WITH temp_t1 AS (
    SELECT 
        MIN("Milliseconds") AS Limit1,
        AVG("Milliseconds") AS avg_milliseconds,
        (avg_milliseconds + MIN("Milliseconds")) / 2 AS Limit2,
        (MAX("Milliseconds") + avg_milliseconds) / 2 AS Limit3,
        MAX("Milliseconds") AS Limit4
    FROM MUSIC.MUSIC.TRACK
),
categ AS (
    SELECT 
        "TrackId",
        CASE 
            WHEN t."Milliseconds" < (SELECT Limit2 FROM temp_t1) THEN 'Short'
            WHEN t."Milliseconds" < (SELECT Limit3 FROM temp_t1) THEN 'Medium'
            WHEN t."Milliseconds" <= (SELECT Limit4 FROM temp_t1) THEN 'Long'
        END AS LengthCateg
    FROM MUSIC.MUSIC.TRACK t
)
SELECT 
    CASE 
        WHEN c.LengthCateg = 'Short' THEN (SELECT Limit1 / 60000.0 FROM temp_t1)
        WHEN c.LengthCateg = 'Medium' THEN (SELECT Limit2 / 60000.0 FROM temp_t1)
        WHEN c.LengthCateg = 'Long' THEN (SELECT Limit3 / 60000.0 FROM temp_t1)
    END AS From_Minutes,
    CASE 
        WHEN c.LengthCateg = 'Short' THEN (SELECT Limit2 / 60000.0 FROM temp_t1)
        WHEN c.LengthCateg = 'Medium' THEN (SELECT Limit3 / 60000.0 FROM temp_t1)
        WHEN c.LengthCateg = 'Long' THEN (SELECT Limit4 / 60000.0 FROM temp_t1)
    END AS To_Minutes,
    c.LengthCateg,
    SUM(i."UnitPrice" * i."Quantity") AS TotalPrice
FROM categ c
JOIN MUSIC.MUSIC.INVOICELINE i ON c."TrackId" = i."TrackId"
GROUP BY c.LengthCateg
HAVING c.LengthCateg IS NOT NULL
ORDER BY TotalPrice;
