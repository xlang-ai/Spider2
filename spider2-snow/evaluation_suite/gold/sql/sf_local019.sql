SELECT w1."name" as wrestler1, w2."name" as wrestler2
FROM WWE.WWE.MATCHES m
JOIN WWE.WWE.WRESTLERS w1 ON m."winner_id" = w1."id"::VARCHAR
JOIN WWE.WWE.WRESTLERS w2 ON m."loser_id" = w2."id"::VARCHAR
WHERE m."title_id" IN (SELECT "id"::VARCHAR FROM WWE.WWE.BELTS WHERE "name" LIKE '%NXT%') 
AND m."title_change" = 0 
AND m."duration" IS NOT NULL 
AND m."duration" != '' 
ORDER BY m."duration" ASC 
LIMIT 1