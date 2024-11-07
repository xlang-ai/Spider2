WITH source AS (
    SELECT * 
    FROM {{ source('northwind', 'customer') }}
)
SELECT
    *,
    get_current_timestamp() AS ingestion_timestamp
FROM source
