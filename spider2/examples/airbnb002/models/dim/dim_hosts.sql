{{
	config(
		materialized="incremental" ,
		alias="dim_hosts" ,
		schema="main" ,
		unique_key="HOST_ID"
	)
}}

WITH src_listings_cte AS (
	SELECT *
	FROM {{ref('src_hosts')}}
)

SELECT
	HOST_ID ,
	COALESCE(HOST_NAME,'anonymous') AS HOST_NAME ,
	IS_SUPERHOST ,
	CREATED_AT ,
	UPDATED_AT
FROM
	src_listings_cte

	