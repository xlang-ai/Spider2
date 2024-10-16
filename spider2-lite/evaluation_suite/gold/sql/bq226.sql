SELECT
    CONCAT("https://cronoscan.com/address/", t.from_address) AS cronoscan_link,
FROM
    `spider2-public-data.goog_blockchain_cronos_mainnet_us.transactions` AS t
INNER JOIN
    `spider2-public-data.goog_blockchain_cronos_mainnet_us.blocks` AS b
ON
    b.block_hash = t.block_hash
WHERE
    t.to_address IS NOT NULL
AND
    b.size > 4096
AND
    b.block_timestamp > TIMESTAMP("2023-01-01 00:00:00")
AND
    t.block_timestamp > TIMESTAMP("2023-01-01 00:00:00")
GROUP BY
    t.from_address
ORDER BY
    COUNT(*) 
DESC
LIMIT 1;