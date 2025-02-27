WITH _fips AS (
    SELECT
        state_fips_code
    FROM
        `bigquery-public-data.census_utility.fips_codes_states`
    WHERE
        state_name = "Colorado"
),

_bg AS (
    SELECT
        b.geo_id,
        b.blockgroup_geom,
        ST_AREA(b.blockgroup_geom) AS bg_size
    FROM
        `bigquery-public-data.geo_census_blockgroups.us_blockgroups_national` b
    JOIN
        _fips u ON b.state_fips_code = u.state_fips_code
),

_zip AS (
    SELECT
        z.zip_code,
        z.zip_code_geom
    FROM
        `bigquery-public-data.geo_us_boundaries.zip_codes` z
    JOIN
        _fips u ON z.state_fips_code = u.state_fips_code
),

bq_zip_overlap AS (
    SELECT
        b.geo_id,
        z.zip_code,
        ST_AREA(ST_INTERSECTION(b.blockgroup_geom, z.zip_code_geom)) / b.bg_size AS overlap_size,
        b.blockgroup_geom
    FROM
        _zip z
    JOIN
        _bg b ON ST_INTERSECTS(b.blockgroup_geom, z.zip_code_geom)
),

locations AS (
    SELECT
        SUM(overlap_size * count_locations) AS locations_per_bg,
        l.zip_code
    FROM (
        SELECT
            COUNT(CONCAT(institution_name, " : ", branch_name)) AS count_locations,
            zip_code
        FROM
            `bigquery-public-data.fdic_banks.locations`
        WHERE
            state IS NOT NULL
            AND state_name IS NOT NULL
        GROUP BY
            zip_code
    ) l
    JOIN
        bq_zip_overlap ON l.zip_code = bq_zip_overlap.zip_code
    GROUP BY
        l.zip_code
)

SELECT
    l.zip_code
FROM
    locations l
GROUP BY
    l.zip_code
ORDER BY
    MAX(locations_per_bg) DESC
LIMIT 1;