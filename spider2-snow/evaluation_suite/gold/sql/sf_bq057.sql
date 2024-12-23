WITH totals AS (
    -- Aggregate monthly totals for Bitcoin txs, input/output UTXOs,
    -- and input/output values (UTXO stands for Unspent Transaction Output)
    SELECT
        "txs_tot"."block_timestamp_month" AS tx_month,
        COUNT("txs_tot"."hash") AS tx_count,
        SUM("txs_tot"."input_count") AS tx_inputs,
        SUM("txs_tot"."output_count") AS tx_outputs,
        SUM("txs_tot"."input_value") / 100000000 AS tx_input_val,
        SUM("txs_tot"."output_value") / 100000000 AS tx_output_val
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS AS "txs_tot"
    WHERE "txs_tot"."block_timestamp_month" BETWEEN CAST('2021-01-01' AS DATE) AND CAST('2021-12-31' AS DATE)
    GROUP BY "txs_tot"."block_timestamp_month"
    ORDER BY "txs_tot"."block_timestamp_month" DESC
),
coinjoinOuts AS (
    -- Builds a table where each row represents an output of a 
    -- potential CoinJoin tx, defined as a tx that had more 
    -- than two outputs and had a total output value less than its
    -- input value, per Adam Fiscor's description in this article: 
    SELECT 
        "txs"."hash",
        "txs"."block_number",
        "txs"."block_timestamp_month",
        "txs"."input_count",
        "txs"."output_count",
        "txs"."input_value",
        "txs"."output_value",
        "o".value:"value" AS "outputs_val"
    FROM CRYPTO.CRYPTO_BITCOIN.TRANSACTIONS AS "txs", 
         LATERAL FLATTEN(INPUT => "txs"."outputs") AS "o"
    WHERE "txs"."output_count" > 2 
      AND "txs"."output_value" <= "txs"."input_value"
      AND "txs"."block_timestamp_month" BETWEEN CAST('2021-01-01' AS DATE) AND CAST('2021-12-31' AS DATE)
    ORDER BY "txs"."block_number", "txs"."hash" DESC
),
coinjoinTxs AS (
    -- Builds a table of just the distinct CoinJoin tx hashes
    -- which had more than one equal-value output.
    SELECT 
        "coinjoinouts"."hash" AS "cjhash",
        "coinjoinouts"."outputs_val" AS outputVal,
        COUNT(*) AS cjOuts
    FROM coinjoinOuts AS "coinjoinouts"
    GROUP BY "coinjoinouts"."hash", "coinjoinouts"."outputs_val"
    HAVING COUNT(*) > 1
),
coinjoinsD AS (
    -- Filter out all potential CoinJoin txs that did not have
    -- more than one equal-value output. Do not list the
    -- outputs themselves, only the distinct tx hashes and
    -- their input/output counts and values.
    SELECT DISTINCT 
        "coinjoinouts"."hash", 
        "coinjoinouts"."block_number", 
        "coinjoinouts"."block_timestamp_month",
        "coinjoinouts"."input_count",
        "coinjoinouts"."output_count",
        "coinjoinouts"."input_value",
        "coinjoinouts"."output_value"
    FROM coinjoinOuts AS "coinjoinouts"
    INNER JOIN coinjoinTxs AS "coinjointxs" 
        ON "coinjoinouts"."hash" = "coinjointxs"."cjhash"
),
coinjoins AS (
    -- Aggregate monthly totals for CoinJoin txs, input/output UTXOs,
    -- and input/output values
    SELECT 
        "cjs"."block_timestamp_month" AS cjs_month,
        COUNT("cjs"."hash") AS cjs_count,
        SUM("cjs"."input_count") AS cjs_inputs,
        SUM("cjs"."output_count") AS cjs_outputs,
        SUM("cjs"."input_value") / 100000000 AS cjs_input_val,
        SUM("cjs"."output_value") / 100000000 AS cjs_output_val
    FROM coinjoinsD AS "cjs"
    GROUP BY "cjs"."block_timestamp_month"
    ORDER BY "cjs"."block_timestamp_month" DESC
)
SELECT EXTRACT(MONTH FROM tx_month) AS month,
    -- Calculate resulting CoinJoin percentages:
    -- tx_percent = percent of monthly Bitcoin txs that were CoinJoins
    ROUND(coinjoins.cjs_count / totals.tx_count * 100, 1) AS tx_percent,
    
    -- utxos_percent = percent of monthly Bitcoin utxos that were CoinJoins
    ROUND((coinjoins.cjs_inputs / totals.tx_inputs + coinjoins.cjs_outputs / totals.tx_outputs) / 2 * 100, 1) AS utxos_percent,
    
    -- value_percent = percent of monthly Bitcoin volume that took place
    -- in CoinJoined transactions
    ROUND(coinjoins.cjs_input_val / totals.tx_input_val * 100, 1) AS value_percent
FROM totals
INNER JOIN coinjoins
    ON totals.tx_month = coinjoins.cjs_month
ORDER BY value_percent DESC
LIMIT 1;
