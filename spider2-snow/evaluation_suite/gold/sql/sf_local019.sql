WITH MatchDetails AS (
    SELECT
        B."name" AS "titles",
        M."duration" AS "match_duration",
        W1."name" || ' vs ' || W2."name" AS "matches",
        M."win_type" AS "win_type",
        L."name" AS "location",
        E."name" AS "event",
        ROW_NUMBER() OVER (PARTITION BY B."name" ORDER BY CAST(SPLIT_PART(M."duration", ':', 1) AS DOUBLE) * 60 + CAST(SPLIT_PART(M."duration", ':', 2) AS DOUBLE) ASC) AS "rank"
    FROM 
        WWE.WWE.BELTS B
    INNER JOIN WWE.WWE.MATCHES M ON M."title_id" = B."id"
    INNER JOIN WWE.WWE.WRESTLERS W1 ON W1."id" = M."winner_id"
    INNER JOIN WWE.WWE.WRESTLERS W2 ON W2."id" = M."loser_id"
    INNER JOIN WWE.WWE.CARDS C ON C."id" = M."card_id"
    INNER JOIN WWE.WWE.LOCATIONS L ON L."id" = C."location_id"
    INNER JOIN WWE.WWE.EVENTS E ON E."id" = C."event_id"
    INNER JOIN WWE.WWE.PROMOTIONS P ON P."id" = C."promotion_id"
    WHERE
        P."name" = 'NXT'
        AND M."duration" <> ''
        AND B."name" <> ''
        AND B."name" NOT IN (
            SELECT "name" 
            FROM WWE.WWE.BELTS 
            WHERE "name" LIKE '%title change%'
        )
),
Rank1 AS (
    SELECT 
        "titles",
        "match_duration",
        "matches",
        "win_type",
        "location",
        "event"
    FROM 
        MatchDetails
    WHERE 
        "rank" = 1
)
SELECT
    SUBSTR("matches", 1, POSITION(' vs ' IN "matches") - 1) AS "wrestler1",
    SUBSTR("matches", POSITION(' vs ' IN "matches") + 4) AS "wrestler2"
FROM
    Rank1
ORDER BY CAST(SPLIT_PART("match_duration", ':', 1) AS DOUBLE) * 60 + CAST(SPLIT_PART("match_duration", ':', 2) AS DOUBLE) 
LIMIT 1