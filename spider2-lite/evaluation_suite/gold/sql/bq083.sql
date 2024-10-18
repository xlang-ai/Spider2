CREATE TEMP FUNCTION IFMINT(input STRING, ifTrue ANY TYPE, ifFalse ANY TYPE) AS (
    CASE
      WHEN input LIKE "0x40c10f19%" THEN ifTrue
    ELSE
    ifFalse
  END
);

CREATE TEMP FUNCTION
  USD(input FLOAT64) AS ( 
    CAST(input AS STRING FORMAT "$999,999,999,999") 
);

SELECT
  DATE(block_timestamp) AS `Date`,
  USD(SUM(IFMINT(input,
        1,
        -1) * CAST(CONCAT("0x", LTRIM(SUBSTRING(input, IFMINT(input,
                75,
                11), 64), "0")) AS FLOAT64) / 1000000)) AS `Δ Total Market Value`
FROM
  `bigquery-public-data.crypto_ethereum.transactions`
WHERE
  DATE(block_timestamp) BETWEEN "2024-01-01"
  AND "2024-01-14"
  AND to_address = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48" -- USDC Token
  AND (input LIKE "0x42966c68%" -- Burn
    OR input LIKE "0x40c10f19%" -- Mint
    )
GROUP BY
  `Date`
ORDER BY
  `Date` DESC;