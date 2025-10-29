WITH "FILTERED_TX" AS (
    SELECT
        t."hash",
        t."from_address",
        COALESCE(t."to_address", t."receipt_contract_address") AS "to_address",
        COALESCE(t."value", 0) AS "value",
        COALESCE(t."receipt_gas_used", 0) AS "receipt_gas_used",
        COALESCE(t."gas_price", 0) AS "gas_price",
        COALESCE(t."receipt_gas_used", 0) * COALESCE(t."gas_price", 0) AS "gas_fee",
        b."miner"
    FROM
        CRYPTO.CRYPTO_ETHEREUM_CLASSIC."TRANSACTIONS" t
        JOIN CRYPTO.CRYPTO_ETHEREUM_CLASSIC."BLOCKS" b
            ON t."block_number" = b."number"
    WHERE
        t."receipt_status" = 1
        AND TO_DATE(TO_TIMESTAMP_NTZ(t."block_timestamp" / 1000000)) = '2016-10-14'
),
"ADDRESS_CHANGES" AS (
    SELECT
        "address",
        SUM("amount") AS "net_change"
    FROM (
        SELECT
            t."from_address" AS "address",
            -CAST(t."value" AS NUMBER(38, 9)) AS "amount"
        FROM
            "FILTERED_TX" t
        UNION ALL
        SELECT
            t."to_address" AS "address",
            CAST(t."value" AS NUMBER(38, 9)) AS "amount"
        FROM
            "FILTERED_TX" t
        WHERE
            t."to_address" IS NOT NULL
        UNION ALL
        SELECT
            t."from_address" AS "address",
            -CAST(t."gas_fee" AS NUMBER(38, 9)) AS "amount"
        FROM
            "FILTERED_TX" t
        UNION ALL
        SELECT
            t."miner" AS "address",
            CAST(t."gas_fee" AS NUMBER(38, 9)) AS "amount"
        FROM
            "FILTERED_TX" t
    ) AS contributions
    WHERE
        "address" IS NOT NULL
    GROUP BY
        "address"
),
"MAX_ADDR" AS (
    SELECT
        "address",
        "net_change"
    FROM
        "ADDRESS_CHANGES"
    QUALIFY ROW_NUMBER() OVER (ORDER BY "net_change" DESC, "address") = 1
),
"MIN_ADDR" AS (
    SELECT
        "address",
        "net_change"
    FROM
        "ADDRESS_CHANGES"
    QUALIFY ROW_NUMBER() OVER (ORDER BY "net_change" ASC, "address") = 1
)
SELECT
    metrics."metric",
    metrics."address",
    metrics."net_change"
FROM (
    SELECT
        'MAX' AS "metric",
        max_addr."address",
        COALESCE(max_addr."net_change", stats."max_change", 0) AS "net_change"
    FROM
        (SELECT MAX("net_change") AS "max_change" FROM "ADDRESS_CHANGES") stats
        LEFT JOIN "MAX_ADDR" max_addr ON 1 = 1
    UNION ALL
    SELECT
        'MIN' AS "metric",
        min_addr."address",
        COALESCE(min_addr."net_change", stats."min_change", 0) AS "net_change"
    FROM
        (SELECT MIN("net_change") AS "min_change" FROM "ADDRESS_CHANGES") stats
        LEFT JOIN "MIN_ADDR" min_addr ON 1 = 1
) metrics
ORDER BY
    metrics."metric" DESC;