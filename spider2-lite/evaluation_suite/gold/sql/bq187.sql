WITH tokenInfo AS (
    SELECT address
    FROM `spider2-public-data.ethereum_blockchain.tokens`
    WHERE name = 'BNB'
),

receivedTx AS (
    SELECT tx.to_address as addr, 
           tokens.name as name, 
           SUM(CAST(tx.value AS float64) / POWER(10, 18)) as amount_received
    FROM `spider2-public-data.ethereum_blockchain.token_transfers` as tx
    JOIN tokenInfo ON tx.token_address = tokenInfo.address,
         `spider2-public-data.ethereum_blockchain.tokens` as tokens
    WHERE tx.token_address = tokens.address 
        AND tx.to_address <> '0x0000000000000000000000000000000000000000'
    GROUP BY 1, 2
),

sentTx AS (
    SELECT tx.from_address as addr, 
           tokens.name as name, 
           SUM(CAST(tx.value AS float64) / POWER(10, 18)) as amount_sent
    FROM `spider2-public-data.ethereum_blockchain.token_transfers` as tx
    JOIN tokenInfo ON tx.token_address = tokenInfo.address,
         `spider2-public-data.ethereum_blockchain.tokens` as tokens
    WHERE tx.token_address = tokens.address 
        AND tx.from_address <> '0x0000000000000000000000000000000000000000'
    GROUP BY 1, 2
),

walletBalances AS (
    SELECT r.addr,
           COALESCE(SUM(r.amount_received), 0) - COALESCE(SUM(s.amount_sent), 0) as balance
    FROM 
        receivedTx as r
    LEFT JOIN 
        sentTx as s
    ON 
        r.addr = s.addr
    GROUP BY 
        r.addr
)

SELECT 
    SUM(balance) as circulating_supply
FROM 
    walletBalances;