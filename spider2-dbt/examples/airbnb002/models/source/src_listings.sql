{{
	config(
		materialized="table" ,
		alias="src_listings" ,
		schema="main" ,
		unique_key="LISTING_ID"
	)
}}

WITH RAW_LISTINGS AS (
	SELECT *
	FROM {{source('airbnb','listings')}}
)

SELECT
	  ID AS LISTING_ID ,
	  NAME AS LISTING_NAME ,
	  LISTING_URL ,
	  ROOM_TYPE ,
	  MINIMUM_NIGHTS ,
	  HOST_ID ,
	  PRICE AS PRICE_STR ,
	  CREATED_AT ,
	  UPDATED_AT 
FROM
	RAW_LISTINGS