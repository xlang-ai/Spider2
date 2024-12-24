WITH results AS (
    SELECT
        growth.country_name,
        growth.net_migration,
        CAST(area.country_area as INT64) as country_area
    FROM (
        SELECT
            country_name,
            net_migration,
            country_code
        FROM
            `bigquery-public-data.census_bureau_international.birth_death_growth_rates`
        WHERE
            year = 2017
    ) growth
    INNER JOIN (
        SELECT
            country_area,
            country_code
        FROM
            `bigquery-public-data.census_bureau_international.country_names_area`
        WHERE
            country_area > 500
    ) area
    ON
        growth.country_code = area.country_code
    ORDER BY
        net_migration DESC
    LIMIT 3
)
SELECT country_name, net_migration
FROM results;