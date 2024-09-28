WITH get_june_count AS (
    SELECT
        strftime('%Y', insert_date) AS year,
        COUNT(*) AS june_count
    FROM 
        cities
    WHERE 
        strftime('%m', insert_date) = '04'
    GROUP BY 
        year
    ORDER BY 
        year
),
get_yearly_total AS (
    SELECT
        year,
        june_count,
        LAG(june_count, 1) OVER (ORDER BY year) AS last_year_count
    FROM
        get_june_count
),
get_year_over_year AS (
    SELECT
        year,
        june_count,
        100.0 * (june_count - last_year_count) / 
            (last_year_count * 1.0) AS year_over_year
    FROM
        get_yearly_total
)
SELECT
    year AS year,
    june_count AS cities_inserted,
    year_over_year || '%' AS year_over_year
FROM
    get_year_over_year;