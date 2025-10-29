WITH events AS (
    SELECT
        CASE
            WHEN "topics"[0]::STRING = '0x7a53080ba414158be7ec69b987b5fb7d07dee101fe85488f0853ae16239d0bde' THEN 'MINT'
            ELSE 'BURN'
        END AS "event_type",
        "block_timestamp",
        "block_number",
        "transaction_hash",
        "log_index"
    FROM "CRYPTO"."CRYPTO_ETHEREUM"."LOGS"
    WHERE LOWER("address") = '0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8'
      AND "topics"[0]::STRING IN (
          '0x7a53080ba414158be7ec69b987b5fb7d07dee101fe85488f0853ae16239d0bde',
          '0x0c396cd989a39f4459b5fa1aed6a9a8dcdbc45908acfd67e028cd568da98982c'
      )
),
ranked_events AS (
    SELECT
        "event_type",
        "block_timestamp",
        "block_number",
        "transaction_hash",
        ROW_NUMBER() OVER (
            PARTITION BY "event_type"
            ORDER BY "block_timestamp", "block_number", "log_index"
        ) AS "rn"
    FROM events
)
SELECT
    "event_type",
    TO_TIMESTAMP_NTZ("block_timestamp" / 1000000) AS "block_timestamp",
    "block_number",
    "transaction_hash"
FROM ranked_events
WHERE "rn" <= 5
ORDER BY "block_timestamp", "block_number", "event_type", "transaction_hash"