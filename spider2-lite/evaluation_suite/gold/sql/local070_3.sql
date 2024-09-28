WITH get_dates AS (
    SELECT
        insert_date,
        city_name
    FROM (
        SELECT
            insert_date,
            city_name,
            ROW_NUMBER() OVER (PARTITION BY insert_date ORDER BY insert_date) AS row_num
        FROM
            cities
        WHERE
            country_code_2 = 'ca'
            AND insert_date BETWEEN '2022-04-01' AND '2022-04-30'
    )
    WHERE row_num = 1
),
get_diff AS (
    SELECT
        city_name,
        insert_date,
        CAST(strftime('%d', insert_date) AS INTEGER) - ROW_NUMBER() OVER (ORDER BY insert_date) AS diff
    FROM (
        SELECT
            city_name,
            insert_date,
            ROW_NUMBER() OVER (ORDER BY insert_date) AS row_num
        FROM
            get_dates
    )
),
get_diff_count AS (
    SELECT
        city_name,
        insert_date,
        COUNT(*) OVER (PARTITION BY diff) AS diff_count
    FROM
        get_diff
),
get_rank AS (
    SELECT
        DENSE_RANK() OVER (ORDER BY diff_count DESC) AS rnk,
        insert_date,
        city_name
    FROM
        get_diff_count
)
SELECT
    insert_date AS most_consecutive_dates,
    UPPER(SUBSTR(city_name, 1, 1)) || LOWER(SUBSTR(city_name, 2)) AS city_name
FROM
    get_rank
WHERE
    rnk = 1
ORDER BY
    insert_date;