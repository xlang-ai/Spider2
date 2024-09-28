WITH get_dates AS (
    SELECT
        insert_date,
        country_code_2
    FROM (
        SELECT
            insert_date,
            country_code_2,
            ROW_NUMBER() OVER (PARTITION BY insert_date, country_code_2 ORDER BY insert_date) AS row_num
        FROM
            cities
        WHERE
            insert_date BETWEEN '2022-06-01' AND '2022-06-30'
    )
    WHERE row_num = 1
),
get_diff AS (
    SELECT
        country_code_2,
        insert_date,
        CAST(strftime('%d', insert_date) AS INTEGER) - ROW_NUMBER() OVER (PARTITION BY country_code_2 ORDER BY insert_date) AS diff
    FROM (
        SELECT
            country_code_2,
            insert_date,
            ROW_NUMBER() OVER (PARTITION BY country_code_2 ORDER BY insert_date) AS row_num
        FROM
            get_dates
    )
),
get_diff_count AS (
    SELECT
        country_code_2,
        insert_date,
        COUNT(*) OVER (PARTITION BY country_code_2, diff) AS diff_count
    FROM
        get_diff
),
get_rank AS (
    SELECT
        country_code_2,
        DENSE_RANK() OVER (PARTITION BY country_code_2 ORDER BY diff_count DESC) AS rnk,
        insert_date
    FROM
        get_diff_count
),
count_rank AS(
	SELECT
		country_code_2,
		COUNT(rnk) AS diff_count
	FROM
		get_rank
	GROUP BY 
		country_code_2,
		rnk
)
SELECT
    country_code_2 AS country
FROM
    count_rank
WHERE
	diff_count = (
		SELECT
            MAX(diff_count)
        FROM
            count_rank
	);