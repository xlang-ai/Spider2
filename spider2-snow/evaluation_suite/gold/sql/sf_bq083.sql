SELECT 
  TO_DATE(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)) AS "Date",  -- 将时间戳转换为日期格式，除以1000000
  TO_CHAR(SUM(
      CASE
          WHEN "input" LIKE '0x40c10f19%' THEN 1
          ELSE -1
      END * 
      CAST(CONCAT('0x', LTRIM(SUBSTRING("input", 
                                       CASE 
                                           WHEN "input" LIKE '0x40c10f19%' THEN 75
                                           ELSE 11
                                       END, 64), '0')) AS FLOAT) / 1000000)
  , '$999,999,999,999') AS "Δ Total Market Value"
FROM 
  "CRYPTO"."CRYPTO_ETHEREUM"."TRANSACTIONS"
WHERE 
  TO_DATE(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000)) BETWEEN '2023-01-01' AND '2023-12-31'
  AND "to_address" = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'  -- USDC Token
  AND ("input" LIKE '0x42966c68%' -- Burn
       OR "input" LIKE '0x40c10f19%' -- Mint
  )
GROUP BY 
  TO_DATE(TO_TIMESTAMP_NTZ("block_timestamp" / 1000000))
ORDER BY 
  "Date" DESC;
