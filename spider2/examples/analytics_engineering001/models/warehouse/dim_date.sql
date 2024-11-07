SELECT
    STRFTIME('%Y-%m-%d', d) AS id,         -- Format date as 'YYYY-MM-DD'
    d                          AS full_date,     -- Full date
    EXTRACT(YEAR FROM d)        AS year,         -- Extract year
    EXTRACT(WEEK FROM d)        AS year_week,    -- Extract week of the year
    EXTRACT(DAY FROM d)         AS year_day,     -- Extract day of the year
    EXTRACT(YEAR FROM d)        AS fiscal_year,  -- Set fiscal year as the same as year
    ((EXTRACT(MONTH FROM d) - 1) / 3 + 1) AS fiscal_qtr, -- Calculate fiscal quarter
    EXTRACT(MONTH FROM d)       AS month,        -- Extract month
    STRFTIME('%B', d)           AS month_name,   -- Format month name
    STRFTIME('%w', d)           AS week_day,     -- Format day of the week (0-6, Sunday is 0)
    STRFTIME('%A', d)           AS day_name,     -- Format day name (e.g., Monday)
    (CASE WHEN STRFTIME('%w', d) IN ('0', '6') THEN 0 ELSE 1 END) AS day_is_weekday -- Check if it's a weekday
FROM (
    SELECT 
        CAST(generate_series AS DATE) AS d  -- Cast timestamp to date
    FROM 
        generate_series(TIMESTAMP '2014-01-01', TIMESTAMP '2050-01-01', INTERVAL 1 DAY) -- Generate date series
) AS foo
