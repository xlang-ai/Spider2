{{
	config(
		materialized="incremental" ,
		alias="fct_reviews" ,
		schema="main"
	)
}}

WITH src_reviews_cte AS (
	SELECT *
	FROM {{ref('src_reviews')}}
)

SELECT * 
FROM src_reviews_cte
WHERE REVIEW_TEXT IS NOT NULL

{% if is_incremental() %}
	AND REVIEW_DATE > (SELECT MAX(REVIEW_DATE)
					   FROM {{ this}}
					   )
{% endif %}