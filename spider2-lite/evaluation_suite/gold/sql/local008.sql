WITH player_stats AS (
    SELECT
        b.player_id,
        p.name_given AS player_name,
        SUM(b.g) AS games_played,
        SUM(b.r) AS runs,
        SUM(b.h) AS hits,
        SUM(b.hr) AS home_runs
    FROM player p
    JOIN batting b ON p.player_id = b.player_id
    GROUP BY b.player_id, p.name_given
)

SELECT 'Games Played' AS Category, player_name AS Player_Name, games_played AS Batting_Table_Topper
FROM player_stats
WHERE games_played = (SELECT MAX(games_played) FROM player_stats)

UNION ALL

SELECT 'Runs' AS Category, player_name AS Player_Name, runs AS Batting_Table_Topper
FROM player_stats
WHERE runs = (SELECT MAX(runs) FROM player_stats)

UNION ALL

SELECT 'Hits' AS Category, player_name AS Player_Name, hits AS Batting_Table_Topper
FROM player_stats
WHERE hits = (SELECT MAX(hits) FROM player_stats)

UNION ALL

SELECT 'Home Runs' AS Category, player_name AS Player_Name, home_runs AS Batting_Table_Topper
FROM player_stats
WHERE home_runs = (SELECT MAX(home_runs) FROM player_stats);
