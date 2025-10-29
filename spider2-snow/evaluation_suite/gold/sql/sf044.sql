WITH "tickers" AS (
    SELECT column1 AS "TICKER"
    FROM (VALUES 
        ('AAPL'),
        ('MSFT'),
        ('GOOGL'),
        ('AMZN'),
        ('NVDA'),
        ('META'),
        ('TSLA')
    ) AS "v"(column1)
),
"filtered" AS (
    SELECT
        "s"."TICKER",
        "s"."DATE",
        "s"."VALUE"
    FROM "FINANCE__ECONOMICS"."CYBERSYN"."STOCK_PRICE_TIMESERIES" AS "s"
    INNER JOIN "tickers" AS "t"
        ON "s"."TICKER" = "t"."TICKER"
    WHERE "s"."VARIABLE" = 'post-market_close'
        AND "s"."DATE" BETWEEN '2024-01-01' AND '2024-06-30'
),
"start_prices" AS (
    SELECT
        "TICKER",
        "DATE" AS "START_DATE",
        "VALUE" AS "START_VALUE"
    FROM (
        SELECT
            "TICKER",
            "DATE",
            "VALUE",
            ROW_NUMBER() OVER (PARTITION BY "TICKER" ORDER BY "DATE") AS "RN"
        FROM "filtered"
    )
    WHERE "RN" = 1
),
"end_prices" AS (
    SELECT
        "TICKER",
        "DATE" AS "END_DATE",
        "VALUE" AS "END_VALUE"
    FROM (
        SELECT
            "TICKER",
            "DATE",
            "VALUE",
            ROW_NUMBER() OVER (PARTITION BY "TICKER" ORDER BY "DATE" DESC) AS "RN"
        FROM "filtered"
    )
    WHERE "RN" = 1
),
"split_candidates" AS (
    SELECT
        "TICKER",
        "DATE",
        "PREV_VALUE" / NULLIF("VALUE", 0) AS "RATIO"
    FROM (
        SELECT
            "TICKER",
            "DATE",
            "VALUE",
            LAG("VALUE") OVER (PARTITION BY "TICKER" ORDER BY "DATE") AS "PREV_VALUE"
        FROM "filtered"
    )
    WHERE "PREV_VALUE" IS NOT NULL
),
"split_factors" AS (
    SELECT
        "TICKER",
        EXP(SUM(LN(ROUND("RATIO")))) AS "TOTAL_FACTOR"
    FROM "split_candidates"
    WHERE "RATIO" >= 1.5
      AND ABS("RATIO" - ROUND("RATIO")) <= 0.2
    GROUP BY "TICKER"
)
SELECT
    "sp"."TICKER",
    "sp"."START_DATE",
    "ep"."END_DATE",
    ROUND("sp"."START_VALUE" / COALESCE("sf"."TOTAL_FACTOR", 1), 2) AS "ADJUSTED_START_PRICE",
    ROUND("ep"."END_VALUE", 2) AS "END_PRICE",
    ROUND((("ep"."END_VALUE" - ("sp"."START_VALUE" / COALESCE("sf"."TOTAL_FACTOR", 1))) / ("sp"."START_VALUE" / COALESCE("sf"."TOTAL_FACTOR", 1))) * 100, 2) AS "PERCENT_CHANGE"
FROM "start_prices" AS "sp"
INNER JOIN "end_prices" AS "ep"
    ON "sp"."TICKER" = "ep"."TICKER"
LEFT JOIN "split_factors" AS "sf"
    ON "sp"."TICKER" = "sf"."TICKER"
ORDER BY "sp"."TICKER";