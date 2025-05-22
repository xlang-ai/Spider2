WITH customer_cte AS (
	SELECT DISTINCT
	    {{ dbt_utils.generate_surrogate_key(['CustomerID', 'Country']) }} as customer_id,
	    Country AS country
	FROM {{ source('retail', 'raw_invoices') }}
	WHERE CustomerID IS NOT NULL
)
SELECT
    t.*
FROM customer_cte t