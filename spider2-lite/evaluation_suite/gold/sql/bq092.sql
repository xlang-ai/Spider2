WITH double_entry_book AS (
    -- debits
    SELECT
      ARRAY_TO_STRING(inputs.addresses, ",") AS address,
      inputs.type,
      - inputs.value AS value
    FROM
        `spider2-public-data.crypto_dash.transactions`
    JOIN
        UNNEST(inputs) AS inputs
    WHERE block_timestamp_month = '2023-04-01'

    UNION ALL
 
    -- credits
    SELECT
      ARRAY_TO_STRING(outputs.addresses, ",") AS address,
      outputs.type,
      outputs.value AS value
    FROM
        `spider2-public-data.crypto_dash.transactions` JOIN UNNEST(outputs) AS outputs
    WHERE block_timestamp_month = '2023-04-01'
),
address_balances AS (
    SELECT 
        address,
        type,
        SUM(value) AS balance
    FROM double_entry_book
    GROUP BY 1, 2
)
SELECT
    MAX(balance) AS max_balance,
    MIN(balance) AS min_balance
FROM address_balances;