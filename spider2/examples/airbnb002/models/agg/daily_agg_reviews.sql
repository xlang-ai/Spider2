{{
	config(
		materialized="incremental" ,
		alias="daily_agg_reviews" ,
		schema="main",
		unique_key="DATE_SENTIMENT_ID"
	)
}}

WITH review_cte AS (
	SELECT *
	FROM {{ref('fct_reviews')}}
)

SELECT
	COUNT(*) AS REVIEW_TOTALS ,
	REVIEW_SENTIMENT ,
	REVIEW_DATE::DATE AS REVIEW_DATE ,
	{{dbt_utils.surrogate_key(['REVIEW_SENTIMENT','REVIEW_DATE'])}} AS DATE_SENTIMENT_ID
FROM review_cte

{% if is_incremental() %}

WHERE REVIEW_DATE = CURRENT_DATE

{% endif %}

GROUP BY
	REVIEW_DATE,
	REVIEW_SENTIMENT,
	DATE_SENTIMENT_ID
ORDER BY
	REVIEW_DATE DESC,
	REVIEW_SENTIMENT