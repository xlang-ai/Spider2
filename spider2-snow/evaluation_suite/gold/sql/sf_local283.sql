WITH per_team_match AS (
  SELECT
    m."season",
    m."league_id",
    m."home_team_api_id" AS "team_api_id",
    m."home_team_goal" AS "gf",
    m."away_team_goal" AS "ga",
    CASE
      WHEN m."home_team_goal" > m."away_team_goal" THEN 3
      WHEN m."home_team_goal" = m."away_team_goal" THEN 1
      ELSE 0
    END AS "points"
  FROM "EU_SOCCER"."EU_SOCCER"."MATCH" AS m
  WHERE m."home_team_goal" IS NOT NULL AND m."away_team_goal" IS NOT NULL
  UNION ALL
  SELECT
    m."season",
    m."league_id",
    m."away_team_api_id" AS "team_api_id",
    m."away_team_goal" AS "gf",
    m."home_team_goal" AS "ga",
    CASE
      WHEN m."away_team_goal" > m."home_team_goal" THEN 3
      WHEN m."away_team_goal" = m."home_team_goal" THEN 1
      ELSE 0
    END AS "points"
  FROM "EU_SOCCER"."EU_SOCCER"."MATCH" AS m
  WHERE m."home_team_goal" IS NOT NULL AND m."away_team_goal" IS NOT NULL
),
team_season_points AS (
  SELECT
    p."season",
    p."league_id",
    p."team_api_id",
    SUM(p."points") AS "total_points",
    SUM(p."gf") AS "goals_for",
    SUM(p."ga") AS "goals_against"
  FROM per_team_match p
  GROUP BY p."season", p."league_id", p."team_api_id"
),
ranked_champions AS (
  SELECT
    tsp."season",
    tsp."league_id",
    tsp."team_api_id",
    tsp."total_points",
    tsp."goals_for",
    tsp."goals_against",
    ROW_NUMBER() OVER (
      PARTITION BY tsp."season", tsp."league_id"
      ORDER BY tsp."total_points" DESC,
               (tsp."goals_for" - tsp."goals_against") DESC,
               tsp."goals_for" DESC,
               t."team_long_name" ASC
    ) AS "rn"
  FROM team_season_points tsp
  JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" t
    ON tsp."team_api_id" = t."team_api_id"
)
SELECT
  rc."season",
  t."team_long_name" AS "champion_team",
  l."name" AS "league",
  c."name" AS "country",
  rc."total_points"
FROM ranked_champions rc
JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" t
  ON rc."team_api_id" = t."team_api_id"
JOIN "EU_SOCCER"."EU_SOCCER"."LEAGUE" l
  ON rc."league_id" = l."id"
JOIN "EU_SOCCER"."EU_SOCCER"."COUNTRY" c
  ON l."country_id" = c."id"
WHERE rc."rn" = 1
ORDER BY rc."season", c."name", l."name", "champion_team";