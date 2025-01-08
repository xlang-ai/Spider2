WITH MatchDetails AS (
    SELECT
        b.name AS titles,
        m.duration AS match_duration,
        w1.name || ' vs ' || w2.name AS matches,
        m.win_type AS win_type,
        l.name AS location,
        e.name AS event,
        ROW_NUMBER() OVER (PARTITION BY b.name ORDER BY m.duration ASC) AS rank
    FROM 
        Belts b
    INNER JOIN Matches m ON m.title_id = b.id
    INNER JOIN Wrestlers w1 ON w1.id = m.winner_id
    INNER JOIN Wrestlers w2 ON w2.id = m.loser_id
    INNER JOIN Cards c ON c.id = m.card_id
    INNER JOIN Locations l ON l.id = c.location_id
    INNER JOIN Events e ON e.id = c.event_id
    INNER JOIN Promotions p ON p.id = c.promotion_id
    WHERE
        p.name = 'NXT'
        AND m.duration <> ''
        AND b.name <> ''
        AND b.name NOT IN (
            SELECT name 
            FROM Belts 
            WHERE name LIKE '%title change%'
        )
),
Rank1 AS (
SELECT 
    titles,
    match_duration,
    matches,
    win_type,
    location,
    event
FROM 
    MatchDetails
WHERE 
    rank = 1
)
SELECT
    SUBSTR(matches, 1, INSTR(matches, ' vs ') - 1) AS wrestler1,
    SUBSTR(matches, INSTR(matches, ' vs ') + 4) AS wrestler2
FROM
Rank1
ORDER BY match_duration 
LIMIT 1