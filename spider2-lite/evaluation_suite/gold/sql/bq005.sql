WITH block_rows AS (
  SELECT *, 
         ROW_NUMBER() OVER (ORDER BY timestamp) AS row_num
  FROM 
      `bigquery-public-data.crypto_bitcoin.blocks` 
), 

miner_block_interval AS (
    SELECT row_a.timestamp AS block_time, 
           row_a.number AS block_number,
           TIMESTAMP_DIFF(row_a.timestamp,row_b.timestamp, SECOND) AS delta_block_time
    FROM 
        block_rows row_b
    JOIN block_rows row_a
    ON row_b.row_num = row_a.row_num-1
    ORDER BY 
        row_a.timestamp
),

block_interval_by_date AS (
  SELECT DATE(block_time) AS date, 
         AVG(delta_block_time) AS mean_block_interval
  FROM 
      miner_block_interval
  WHERE 
      block_number > 1 AND EXTRACT(YEAR FROM block_time) = 2023
  GROUP BY 
      date
)

SELECT * 
FROM 
    block_interval_by_date
ORDER BY date
LIMIT 10;