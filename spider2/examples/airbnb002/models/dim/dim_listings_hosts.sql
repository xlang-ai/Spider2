{{
	config(
		materialized="incremental" ,
		alias="dim_listings_hosts" ,
		schema="main" ,
		unique_key="LISTING_HOST_ID"
	)
}}

WITH listings_cte AS (
	SELECT * 
	FROM {{ref('dim_listings')}}
),

hosts_cte AS (
	SELECT *
	FROM {{ref('dim_hosts')}}
)

SELECT
	listings_cte.CREATED_AT ,
	GREATEST(listings_cte.UPDATED_AT, hosts_cte.UPDATED_AT) AS UPDATED_AT ,
	listings_cte.LISTING_ID ,
	listings_cte.LISTING_NAME ,
	listings_cte.ROOM_TYPE ,
	listings_cte.minimum_nights ,
	listings_cte.PRICE ,
	listings_cte.HOST_ID ,
	hosts_cte.HOST_NAME ,
	hosts_cte.IS_SUPERHOST ,
	{{dbt_utils.surrogate_key(['listings_cte.LISTING_ID','hosts_cte.HOST_ID'])}} AS LISTING_HOST_ID
FROM listings_cte
LEFT JOIN hosts_cte
	ON listings_cte.HOST_ID = hosts_cte.HOST_ID