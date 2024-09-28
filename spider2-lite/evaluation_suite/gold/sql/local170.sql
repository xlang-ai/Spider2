WITH RECURSIVE generate_series AS (
    SELECT 
        0 AS period
    UNION ALL
    SELECT 
        period + 1
    FROM 
        generate_series
    WHERE 
        period < 10
),
legislators_first_term AS (
    SELECT 
        id_bioguide,
        MIN(term_start) AS first_term,
        (SELECT state FROM legislators_terms lt2
        WHERE lt2.id_bioguide = lt1.id_bioguide
        ORDER BY term_start LIMIT 1) AS first_state
    FROM 
        legislators_terms lt1
    GROUP BY 
        id_bioguide
),
cohort AS (
    SELECT 
        b.gender, 
        a.first_state, 
        COUNT(DISTINCT a.id_bioguide) AS cohort_size
    FROM 
        legislators_first_term a
    JOIN 
        legislators b ON a.id_bioguide = b.id_bioguide
    GROUP BY 
        b.gender, 
        a.first_state
),
retained_cohort AS (
    SELECT 
        d.first_state,
        g.gender,
        IFNULL((strftime('%Y', f.date) - strftime('%Y', d.first_term)), 0) AS period,
        COUNT(DISTINCT d.id_bioguide) AS cohort_retained
    FROM 
        legislators_first_term d
    JOIN 
        legislators_terms e ON d.id_bioguide = e.id_bioguide
    LEFT JOIN 
        legislation_date_dim f ON f.date BETWEEN e.term_start AND e.term_end
                         AND strftime('%m', f.date) = '12'
                         AND strftime('%d', f.date) = '31'
    JOIN 
        legislators g ON d.id_bioguide = g.id_bioguide
    GROUP BY 
        d.first_state, 
        g.gender, period
),
cohort_retained_pct AS (
    SELECT 
        c.gender, 
        c.first_state, 
        gs.period, 
        c.cohort_size,
        COALESCE(rc.cohort_retained, 0) AS cohort_retained,
        COALESCE(rc.cohort_retained, 0) * 1.0 / c.cohort_size AS pct_retained
    FROM 
        cohort c
    CROSS JOIN 
        generate_series gs
    LEFT JOIN 
        retained_cohort rc ON c.first_state = rc.first_state AND c.gender = rc.gender AND gs.period = rc.period
),
non_zero_states AS (
    SELECT 
        first_state
    FROM 
        cohort_retained_pct
    WHERE 
        period IN (0, 2, 4, 6, 8, 10)
    GROUP BY 
        first_state
    HAVING 
        COUNT(DISTINCT period) = 6
       AND SUM(CASE WHEN pct_retained = 0 THEN 1 ELSE 0 END) = 0
)
SELECT DISTINCT 
    first_state AS state
FROM 
    non_zero_states;