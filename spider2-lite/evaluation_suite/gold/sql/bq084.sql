SELECT
  COUNT(*) AS TXN_COUNT_PER_MONTH,
  COUNT(*) / 
    CASE 
      WHEN EXTRACT(MONTH FROM MIN(txn.block_timestamp)) IN (1, 3, 5, 7, 8, 10, 12) THEN 2678400
      WHEN EXTRACT(MONTH FROM MIN(txn.block_timestamp)) = 2 THEN 
        CASE 
          WHEN MOD(EXTRACT(YEAR FROM MIN(txn.block_timestamp)), 4) = 0 AND (MOD(EXTRACT(YEAR FROM MIN(txn.block_timestamp)), 100) != 0 OR MOD(EXTRACT(YEAR FROM MIN(txn.block_timestamp)), 400) = 0) THEN 2505600
          ELSE 2419200
        END
      ELSE 2592000
    END AS TXN_PER_SECOND,
  EXTRACT(YEAR FROM MIN(txn.block_timestamp)) AS YEAR,
  EXTRACT(MONTH FROM MIN(txn.block_timestamp)) AS MONTH
FROM
  `spider2-public-data.goog_blockchain_polygon_mainnet_us.transactions` AS txn
WHERE EXTRACT(YEAR FROM txn.block_timestamp) = 2023
GROUP BY
  EXTRACT(YEAR FROM txn.block_timestamp),
  EXTRACT(MONTH FROM txn.block_timestamp)
ORDER BY TXN_COUNT_PER_MONTH DESC;