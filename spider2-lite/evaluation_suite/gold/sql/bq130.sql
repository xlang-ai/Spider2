WITH StateCases AS (
    SELECT
        b.state_name,
        b.date,
        b.confirmed_cases - a.confirmed_cases AS daily_new_cases
    FROM 
        (SELECT
            state_name,
            state_fips_code,
            confirmed_cases,
            DATE_ADD(date, INTERVAL 1 DAY) AS date_shift
        FROM
            `bigquery-public-data.covid19_nyt.us_states`
        WHERE
            date >= '2020-02-29' AND date <= '2020-05-30'
        ) a
    JOIN
        `bigquery-public-data.covid19_nyt.us_states` b 
        ON a.state_fips_code = b.state_fips_code AND a.date_shift = b.date
    WHERE
        b.date >= '2020-03-01' AND b.date <= '2020-05-31'
),
RankedStatesPerDay AS (
    SELECT
        state_name,
        date,
        daily_new_cases,
        RANK() OVER (PARTITION BY date ORDER BY daily_new_cases DESC) as rank
    FROM
        StateCases
),
TopStates AS (
    SELECT
        state_name,
        COUNT(*) AS appearance_count
    FROM
        RankedStatesPerDay
    WHERE
        rank <= 5
    GROUP BY
        state_name
    ORDER BY
        appearance_count DESC
),
FourthState AS (
    SELECT
        state_name
    FROM
        TopStates
    LIMIT 1
    OFFSET 3
),
CountyCases AS (
    SELECT
        b.county,
        b.date,
        b.confirmed_cases - a.confirmed_cases AS daily_new_cases
    FROM 
        (SELECT
            county,
            county_fips_code,
            confirmed_cases,
            DATE_ADD(date, INTERVAL 1 DAY) AS date_shift
        FROM
            `bigquery-public-data.covid19_nyt.us_counties`
        WHERE
            date >= '2020-02-29' AND date <= '2020-05-30'
        ) a
    JOIN
        `bigquery-public-data.covid19_nyt.us_counties` b 
        ON a.county_fips_code = b.county_fips_code AND a.date_shift = b.date
    WHERE
        b.date >= '2020-03-01' AND b.date <= '2020-05-31'
        AND b.state_name = (SELECT state_name FROM FourthState)
),
RankedCountiesPerDay AS (
    SELECT
        county,
        date,
        daily_new_cases,
        RANK() OVER (PARTITION BY date ORDER BY daily_new_cases DESC) as rank
    FROM
        CountyCases
),
TopCounties AS (
    SELECT
        county,
        COUNT(*) AS appearance_count
    FROM
        RankedCountiesPerDay
    WHERE
        rank <= 5
    GROUP BY
        county
    ORDER BY
        appearance_count DESC
    LIMIT 5
)
SELECT
    county
FROM
    TopCounties;
