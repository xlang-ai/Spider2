WITH parsed_aggregator_oracle_requests AS (
    SELECT ARRAY(
        SELECT JSON_EXTRACT_SCALAR(symbol_as_json, '$')
        FROM UNNEST(JSON_EXTRACT_ARRAY(decoded_result.calldata, "$.symbols")) AS symbol_as_json
    ) AS symbols,
    CAST(JSON_EXTRACT_SCALAR(decoded_result.calldata, "$.multiplier") AS FLOAT64) AS multiplier,
    ARRAY(
        SELECT CAST(JSON_EXTRACT_SCALAR(rate_as_json, '$') AS FLOAT64)
        FROM UNNEST(JSON_EXTRACT_ARRAY(decoded_result.result, "$.rates")) AS rate_as_json
    ) AS rates,
    block_timestamp,
    oracle_request_id,
    FROM `spider2-public-data.crypto_band.oracle_requests`
    WHERE request.oracle_script_id = 3
),
-- zip symbols and rates
zipped_rates AS (
    SELECT block_timestamp,
        oracle_request_id,
        struct(symbol, rates[OFFSET(off)] AS rate) AS zipped,
        multiplier,
    FROM parsed_aggregator_oracle_requests,
        UNNEST(symbols) AS symbol WITH OFFSET off
),
-- adjust for multiplier
adjusted_rates AS (
    SELECT 
        block_timestamp,
        oracle_request_id,
        struct(zipped.symbol, IEEE_DIVIDE(zipped.rate, multiplier) AS rate) AS zipped,
    FROM zipped_rates
)
SELECT 
    block_timestamp,
    oracle_request_id,
    zipped.symbol,
    zipped.rate,
FROM adjusted_rates
ORDER BY block_timestamp DESC
LIMIT 10