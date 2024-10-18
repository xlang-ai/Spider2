WITH a AS (
    SELECT 
        DATE(block_timestamp) AS date, 
        COUNT(*) AS contracts_creation
    FROM  
        `spider2-public-data.crypto_ethereum.traces` AS traces
    WHERE 
        block_timestamp < '2022-01-01 00:00:00'
        AND trace_type = 'create'
        AND trace_address IS null
    GROUP BY 
        date
),
b AS (
    SELECT 
        date, 
        SUM(contracts_creation) OVER (ORDER BY date) AS ccc, 
        LEAD(date, 1) OVER (ORDER BY date) AS next_date
    FROM 
        a
    ORDER BY 
        date
),
calendar AS (
    SELECT 
        date
    FROM 
        UNNEST(generate_date_array('2017-01-01', '2021-12-31')) AS date
),
c AS (
    SELECT 
        calendar.date, 
        b.ccc
    FROM 
        b 
    JOIN 
        calendar 
    ON 
        b.date <= calendar.date
        AND calendar.date < b.next_date
    ORDER BY 
        calendar.date
),
d AS (
    SELECT 
        DATE(block_timestamp) AS date1, 
        COUNT(*) AS contracts_creation1
    FROM  
        `spider2-public-data.crypto_ethereum.traces` AS traces
    WHERE 
        block_timestamp < '2022-01-01 00:00:00'
        AND trace_type = 'create'
        AND trace_address IS NOT null
    GROUP BY 
        date1
),
e AS (
    SELECT 
        date1, 
        SUM(contracts_creation1) OVER (ORDER BY date1) AS ccc1, 
        LEAD(date1, 1) OVER (ORDER BY date1) AS next_date1
    FROM 
        d
    ORDER BY 
        date1
),
calendar1 AS (
    SELECT 
        date1
    FROM 
        UNNEST(generate_date_array('2017-01-01', '2021-12-31')) AS date1
),
f AS (
    SELECT 
        calendar1.date1, 
        e.ccc1
    FROM 
        e 
    JOIN 
        calendar1 
    ON 
        e.date1 <= calendar1.date1
        AND calendar1.date1 < e.next_date1
    ORDER BY 
        calendar1.date1
)
SELECT 
    f.date1, 
    f.ccc1 AS cumulative_contract_creation_by_contracts, 
    c.ccc AS cumulative_contract_creation_by_users
FROM 
    c 
JOIN 
    f 
ON 
    f.date1 = c.date
ORDER BY 
    f.date1
;