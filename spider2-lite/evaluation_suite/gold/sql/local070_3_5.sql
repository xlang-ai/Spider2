WITH get_dates AS (
    SELECT
        insert_date,
        city_name,
        capital
    FROM (
        SELECT
            insert_date,
            city_name,
            capital,
            ROW_NUMBER() OVER (PARTITION BY insert_date ORDER BY insert_date) AS row_num
        FROM
            cities
        WHERE
            country_code_2 = 'ir'
            AND insert_date BETWEEN '2022-01-01' AND '2022-01-31'
    )
    WHERE row_num = 1
),
get_diff AS (
    SELECT
        city_name,
        insert_date,
        capital,
        CAST(strftime('%d', insert_date) AS INTEGER) - ROW_NUMBER() OVER (ORDER BY insert_date) AS diff
    FROM (
        SELECT
            city_name,
            insert_date,
            capital,
            ROW_NUMBER() OVER (ORDER BY insert_date) AS row_num
        FROM
            get_dates
    )
),
get_diff_count AS (
    SELECT
        city_name,
        insert_date,
        capital,
        COUNT(*) OVER (PARTITION BY diff) AS diff_count
    FROM
        get_diff
),
get_rank AS (
    SELECT
        DENSE_RANK() OVER (ORDER BY diff_count DESC) AS rnk,
        insert_date,
        city_name,
        capital
    FROM
        get_diff_count
),
get_capital AS (
	SELECT 
		capital
	FROM
		cities
	WHERE 
		country_code_2 = 'ir'
	AND 
		insert_date IN (
		SELECT 
			insert_date
		FROM 
			get_rank
		WHERE 
			rnk = 1
		ORDER BY 
    		insert_date
	)
)
SELECT SUM(capital)/(COUNT(capital)*1.0) AS percentage_of_capital
FROM
	get_capital;