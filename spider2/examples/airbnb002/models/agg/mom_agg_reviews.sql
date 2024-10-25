{{
	config(
		materialized="incremental" ,
		alias="mom_agg_reviews" ,
		schema="main",
		unique_key="DATE_SENTIMENT_ID"
	)
}}

WITH review_cte AS (
	SELECT *
	FROM {{ref('fct_reviews')}}

	{% if is_incremental() %}
	WHERE REVIEW_DATE::DATE BETWEEN (SELECT MAX(REVIEW_DATE::DATE) - 29 FROM {{ref('fct_reviews')}}) 
							AND (SELECT MAX(REVIEW_DATE::DATE) FROM {{ref('fct_reviews')}})
	{% endif %}
),

dates_cte AS (
	SELECT DATE_ACTUAL
	FROM airbnb.main.dim_dates
	WHERE DATE_ACTUAL IN (SELECT DISTINCT REVIEW_DATE::DATE
						  FROM review_cte)

	{% if is_incremental() %}
		AND DATE_ACTUAL = (SELECT MAX(REVIEW_DATE::DATE) FROM {{ref('fct_reviews')}})
	{% endif %}
),

final_cte AS (
SELECT
	COUNT(*) AS REVIEW_TOTALS ,
	review_cte.REVIEW_SENTIMENT ,
	dates_cte.DATE_ACTUAL AS AGGREGATION_DATE 
FROM dates_cte
LEFT JOIN review_cte 
	/* joining by last 30 days range so we can get the last 30 days aggregation for each date */
	ON review_cte.REVIEW_DATE::DATE BETWEEN dates_cte.DATE_ACTUAL::DATE - 29
				  		      AND dates_cte.DATE_ACTUAL::DATE
GROUP BY
	REVIEW_SENTIMENT ,
	AGGREGATION_DATE
)

SELECT
	*,
	/*using LAG with 29 days as offset to calculate month over month metrics */
	ROUND(((REVIEW_TOTALS * 100) / LAG(REVIEW_TOTALS,29) OVER (PARTITION BY REVIEW_SENTIMENT 
																ORDER BY AGGREGATION_DATE ASC) - 100),2) AS MOM,
	{{dbt_utils.surrogate_key(['AGGREGATION_DATE','REVIEW_SENTIMENT'])}} AS DATE_SENTIMENT_ID
FROM final_cte