WITH totals AS (
  SELECT
    txs_tot.block_timestamp_month as tx_month,
    count(txs_tot.hash) as tx_count,
    sum(txs_tot.input_count) as tx_inputs,
    sum(txs_tot.output_count) as tx_outputs,
    sum(txs_tot.input_value)/100000000 as tx_input_val,
    sum(txs_tot.output_value)/100000000 as tx_output_val
  FROM `spider2-public-data.crypto_bitcoin.transactions` as txs_tot
  WHERE txs_tot.block_timestamp_month > cast('2023-06-30' as date)
  GROUP BY txs_tot.block_timestamp_month
  ORDER BY txs_tot.block_timestamp_month desc
),
coinjoinOuts AS(
  SELECT 
    txs.hash,
    txs.block_number,
    txs.block_timestamp_month,
    txs.input_count,
    txs.output_count,
    txs.input_value,
    txs.output_value,
    o.value as outputs_val
  FROM `spider2-public-data.crypto_bitcoin.transactions` as txs, UNNEST(txs.outputs) as o
  WHERE output_count > 2 AND 
    output_value <= input_value AND 
    block_timestamp_month > cast('2023-06-30' as date)
  ORDER BY block_number, txs.hash desc
),
coinjoinTxs AS(
  SELECT 
    STRING_AGG(DISTINCT coinjoinOuts.hash LIMIT 1) as cjHash,
    CONCAT(coinjoinOuts.hash, " ", cast(coinjoinOuts.outputs_val as string)) as outputVal,
    count(*) as cjOuts
  FROM coinjoinOuts
  GROUP BY outputVal
  having count(*) >1
),
coinjoinsD AS(
  SELECT 
    DISTINCT coinjoinOuts.hash, 
    coinjoinOuts.block_number, 
    coinjoinOuts.block_timestamp_month,
    coinjoinOuts.input_count,
    coinjoinOuts.output_count,
    coinjoinOuts.input_value,
    coinjoinOuts.output_value
  FROM coinjoinOuts INNER JOIN coinjoinTxs ON coinjoinOuts.hash = coinjoinTxs.cjHash
),
coinjoins AS (
  SELECT 
    block_timestamp_month as cjs_month,
    count(cjs.hash) as cjs_count,
    sum(cjs.input_count) as cjs_inputs,
    sum(cjs.output_count) as cjs_outputs,
    sum(cjs.input_value)/100000000 as cjs_input_val,
    sum(cjs.output_value)/100000000 as cjs_output_val
  FROM coinjoinsD as cjs
  GROUP BY cjs.block_timestamp_month
  ORDER BY cjs.block_timestamp_month desc
)
SELECT 
  coinjoins.cjs_count / totals.tx_count * 100 as tx_percent,
  (coinjoins.cjs_inputs / totals.tx_inputs + coinjoins.cjs_outputs / totals.tx_outputs) / 2 * 100 as utxos_percent,
  coinjoins.cjs_input_val / totals.tx_input_val * 100 as value_percent
  
FROM totals INNER JOIN coinjoins ON totals.tx_month = coinjoins.cjs_month
ORDER BY tx_month desc