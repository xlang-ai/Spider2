WITH RECURSIVE generate_series AS (
    SELECT 1 AS period
    UNION ALL
    SELECT period + 1
    FROM generate_series
    WHERE period < 20
),
legislators_first_term AS (
    SELECT 
        id_bioguide,
        MIN(term_start) AS first_term
    FROM 
        legislators_terms
    GROUP BY 
        id_bioguide
),
cohort AS (
    SELECT 
        COUNT(DISTINCT a.id_bioguide) AS cohort_size
    FROM 
        legislators_first_term a
    WHERE 
        a.first_term BETWEEN '1917-01-01' AND '1999-12-31'
),
retained_cohort AS (
    SELECT 
        (strftime('%Y', f.date) - strftime('%Y', d.first_term)) AS period,
        COUNT(DISTINCT d.id_bioguide) AS cohort_retained
    FROM 
        legislators_first_term d
    JOIN 
        legislators_terms e ON d.id_bioguide = e.id_bioguide
    LEFT JOIN 
        legislation_date_dim f ON f.date BETWEEN e.term_start AND e.term_end
                         AND strftime('%m', f.date) = '12'
                         AND strftime('%d', f.date) = '31'
    WHERE 
        strftime('%Y', f.date) - strftime('%Y', d.first_term) BETWEEN 1 AND 20
    GROUP BY 
        period
)
SELECT 
    gs.period, 
    rc.cohort_retained * 1.0 / c.cohort_size AS retention_rate
FROM 
    generate_series gs
LEFT JOIN 
    retained_cohort rc ON gs.period = rc.period
JOIN 
    cohort c ON 1=1
ORDER BY 
    gs.period;