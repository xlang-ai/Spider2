WITH get_june_count AS (
    SELECT
        strftime('%Y', insert_date) AS year,
        COUNT(*) AS june_count
    FROM 
        cities
    WHERE 
        strftime('%m', insert_date) = '06'
    GROUP BY 
        year
    ORDER BY 
        year
),
get_running_total AS (
    SELECT
        year,
        june_count,
        SUM(june_count) OVER (ORDER BY year) AS total_num_cities
    FROM
        get_june_count
),
get_year_over_year AS (
    SELECT
        year,
        june_count,
        total_num_cities,
        100.0 * (total_num_cities - LAG(total_num_cities, 1) OVER (ORDER BY year)) / 
            (LAG(total_num_cities, 1) OVER (ORDER BY year) * 1.0) AS year_over_year
    FROM
        get_running_total
)
SELECT
    year AS year,
    june_count AS cities_inserted,
    total_num_cities AS running_total,
    year_over_year || '%' AS year_over_year
FROM
    get_year_over_year;