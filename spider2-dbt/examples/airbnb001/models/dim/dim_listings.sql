{{
	config(
		materialized="incremental" ,
		alias="dim_listings" ,
		schema="main" ,
		unique_key="LISTING_ID"
	)
}}

WITH src_listings_cte AS (
	SELECT *
	FROM {{ref('src_listings')}}
)

SELECT
	LISTING_ID ,
	LISTING_NAME ,
	CASE
		WHEN MINIMUM_NIGHTS = 0 THEN 1
		ELSE MINIMUM_NIGHTS
	END AS MINIMUM_NIGHTS ,
	HOST_ID ,
	ROOM_TYPE ,
	REPLACE(PRICE_STR,'$','')::NUMERIC AS PRICE ,
	CREATED_AT ,
	UPDATED_AT 
FROM src_listings_cte


