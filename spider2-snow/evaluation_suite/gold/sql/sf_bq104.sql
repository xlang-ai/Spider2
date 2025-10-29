WITH base AS (
  SELECT
    tr."term",
    tr."week",
    tr."score",
    tr."rank",
    tr."percent_gain",
    tr."refresh_date"
  FROM GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS tr
  WHERE tr."week" IS NOT NULL

  UNION ALL

  SELECT
    ir."term",
    ir."week",
    ir."score",
    ir."rank",
    ir."percent_gain",
    ir."refresh_date"
  FROM GOOGLE_TRENDS.GOOGLE_TRENDS.INTERNATIONAL_TOP_RISING_TERMS ir
  WHERE ir."week" IS NOT NULL
),
latest_refresh AS (
  SELECT MAX("refresh_date") AS "refresh_date"
  FROM base
),
latest_week_in_latest AS (
  SELECT MAX(b."week") AS "week"
  FROM base b
  JOIN latest_refresh lr ON b."refresh_date" = lr."refresh_date"
),
target AS (
  -- Use 52 weeks prior to align with weekly cadence for "exactly one year"
  SELECT DATEADD('week', -52, lw."week") AS "target_week"
  FROM latest_week_in_latest lw
),
cand_exact_latest AS (  -- priority 1: exact target week within latest refresh
  SELECT 1 AS prio, b."refresh_date", b."week"
  FROM base b
  JOIN latest_refresh lr ON b."refresh_date" = lr."refresh_date"
  JOIN target t ON b."week" = t."target_week"
  GROUP BY b."refresh_date", b."week"
),
cand_exact_any AS (     -- priority 2: exact target week across any refresh (choose latest refresh that has it)
  SELECT 2 AS prio, x."refresh_date", x."week"
  FROM (
    SELECT b."refresh_date", b."week",
           ROW_NUMBER() OVER (PARTITION BY b."week" ORDER BY b."refresh_date" DESC) AS rn
    FROM base b
    JOIN target t ON b."week" = t."target_week"
  ) x
  WHERE x.rn = 1
),
candidates AS (
  SELECT * FROM cand_exact_latest
  UNION ALL
  SELECT * FROM cand_exact_any
),
selected_context AS (
  SELECT "refresh_date", "week"
  FROM (
    SELECT "refresh_date", "week",
           ROW_NUMBER() OVER (ORDER BY prio) AS rn
    FROM candidates
  )
  WHERE rn = 1
),
rows_in_context AS (
  SELECT b.*
  FROM base b
  JOIN selected_context sc
    ON b."refresh_date" = sc."refresh_date"
   AND b."week" = sc."week"
),
terms_aggregated AS (
  SELECT
    "term",
    MIN("rank") AS best_rank,
    MAX("percent_gain") AS best_percent_gain,
    MAX("score") AS best_score
  FROM rows_in_context
  GROUP BY "term"
)
SELECT ta."term"
FROM terms_aggregated ta
QUALIFY ROW_NUMBER() OVER (
  ORDER BY ta.best_rank ASC NULLS LAST,
           ta.best_percent_gain DESC NULLS LAST,
           ta.best_score DESC NULLS LAST,
           ta."term"
) = 1;