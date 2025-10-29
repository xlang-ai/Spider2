WITH monthly_transactions AS (
    SELECT 
        EXTRACT(MONTH FROM TO_TIMESTAMP("block_timestamp"/1000000)) as month_num,
        "hash",
        "input_count",
        "output_count", 
        "input_value",
        "output_value",
        "outputs"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS 
    WHERE EXTRACT(YEAR FROM TO_TIMESTAMP("block_timestamp"/1000000)) = 2021
      AND "is_coinbase" = FALSE
),
potential_coinjoins AS (
    SELECT 
        month_num,
        "hash",
        "input_count",
        "output_count",
        "input_value",
        "output_value",
        "outputs"
    FROM monthly_transactions
    WHERE "output_count" > 2
      AND "output_value" <= "input_value"
),
transactions_with_output_values AS (
    SELECT 
        t.month_num,
        t."hash",
        t."input_count",
        t."output_count",
        t."input_value", 
        t."output_value",
        output_flat.value:"value"::NUMBER as output_val
    FROM potential_coinjoins t,
    LATERAL FLATTEN(input => t."outputs") output_flat
),
equal_value_groups AS (
    SELECT 
        month_num,
        "hash",
        "input_count",
        "output_count",
        "input_value",
        "output_value",
        output_val,
        COUNT(*) OVER (PARTITION BY "hash", output_val) as same_value_count
    FROM transactions_with_output_values
    WHERE output_val > 0
),
coinjoin_transactions AS (
    SELECT DISTINCT 
        month_num,
        "hash",
        "input_count", 
        "output_count",
        "input_value",
        "output_value"
    FROM equal_value_groups
    WHERE same_value_count >= 2
),
monthly_coinjoin_stats AS (
    SELECT 
        month_num,
        COUNT(*) as coinjoin_count,
        SUM("input_count") as total_coinjoin_inputs,
        SUM("output_count") as total_coinjoin_outputs,
        SUM("output_value") as total_coinjoin_volume
    FROM coinjoin_transactions
    GROUP BY month_num
),
monthly_total_stats AS (
    SELECT 
        month_num,
        COUNT(*) as total_transactions,
        SUM("input_count") as total_inputs,
        SUM("output_count") as total_outputs,
        SUM("output_value") as total_volume
    FROM monthly_transactions
    GROUP BY month_num
),
monthly_percentages AS (
    SELECT 
        t.month_num,
        COALESCE(c.coinjoin_count, 0) as coinjoin_count,
        t.total_transactions,
        COALESCE(c.total_coinjoin_inputs, 0) as total_coinjoin_inputs,
        COALESCE(c.total_coinjoin_outputs, 0) as total_coinjoin_outputs,
        t.total_inputs,
        t.total_outputs,
        COALESCE(c.total_coinjoin_volume, 0) as total_coinjoin_volume,
        t.total_volume,
        ROUND((COALESCE(c.total_coinjoin_volume, 0)::DECIMAL / t.total_volume) * 100, 1) as pct_volume_coinjoin
    FROM monthly_total_stats t
    LEFT JOIN monthly_coinjoin_stats c ON t.month_num = c.month_num
),
highest_month AS (
    SELECT 
        month_num,
        pct_volume_coinjoin,
        ROW_NUMBER() OVER (ORDER BY pct_volume_coinjoin DESC) as rank
    FROM monthly_percentages
)
SELECT 
    mp.month_num as month_with_highest_coinjoin_pct,
    ROUND((mp.coinjoin_count::DECIMAL / mp.total_transactions) * 100, 1) as pct_transactions_coinjoin,
    ROUND(((mp.total_coinjoin_inputs::DECIMAL / mp.total_inputs) + (mp.total_coinjoin_outputs::DECIMAL / mp.total_outputs)) * 50, 1) as pct_utxos_coinjoin,
    mp.pct_volume_coinjoin
FROM monthly_percentages mp
JOIN highest_month hm ON mp.month_num = hm.month_num
WHERE hm.rank = 1