with _fips AS
    (
        SELECT
            state_fips_code
        FROM
            `bigquery-public-data.census_utility.fips_codes_states`
        WHERE
            state_name = "Florida"
    )

    ,_zip AS
    (
        SELECT
            z.zip_code,
            z.zip_code_geom,
        FROM
            `bigquery-public-data.geo_us_boundaries.zip_codes` z, _fips u
        WHERE
            z.state_fips_code = u.state_fips_code
    )

    ,locations AS
    (
        SELECT
            COUNT(i.institution_name) AS count_locations,
            l.zip_code
        FROM
            `bigquery-public-data.fdic_banks.institutions` i
        JOIN
            `bigquery-public-data.fdic_banks.locations` l 
        USING (fdic_certificate_number)
        WHERE
            l.state IS NOT NULL
        AND 
            l.state_name IS NOT NULL
        GROUP BY 2
    )

    SELECT
        z.zip_code
    FROM
        _zip z
    JOIN
        locations l 
    USING (zip_code)
    GROUP BY
        z.zip_code
    ORDER BY
        SUM(l.count_locations) DESC
    LIMIT 1;