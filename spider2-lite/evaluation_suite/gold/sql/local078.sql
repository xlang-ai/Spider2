WITH get_interest_rank AS (
    SELECT
        t1.month_year,
        t2.interest_name,
        t1.composition,
        RANK() OVER (
            PARTITION BY t2.interest_name
            ORDER BY t1.composition DESC
        ) AS interest_rank
    FROM 
        interest_metrics AS t1
    JOIN 
        interest_map AS t2
    ON 
        t1.interest_id = t2.id
    WHERE 
        t1.month_year IS NOT NULL
),
get_top_10 AS (
    SELECT
        month_year,
        interest_name,
        composition
    FROM 
        get_interest_rank
    WHERE 
        interest_rank = 1
    ORDER BY 
        composition DESC
    LIMIT 10
),
get_bottom_10 AS (
    SELECT
        month_year,
        interest_name,
        composition
    FROM 
        get_interest_rank
    WHERE 
        interest_rank = 1
    ORDER BY 
        composition ASC
    LIMIT 10
)
SELECT * 
FROM 
    get_top_10
UNION
SELECT * 
FROM 
    get_bottom_10
ORDER BY 
    composition DESC;
