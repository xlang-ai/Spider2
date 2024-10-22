{{
	config(
		materialized="table" ,
		alias="src_hosts" ,
		schema="main" ,
		unique_key="HOST_ID"
	)
}}

WITH RAW_HOSTS AS (
	SELECT *
	FROM {{source('airbnb','hosts')}}
)

SELECT
	ID AS HOST_ID ,
	NAME AS HOST_NAME ,
	IS_SUPERHOST ,
	CREATED_AT ,
	UPDATED_AT 
FROM 
	RAW_HOSTS