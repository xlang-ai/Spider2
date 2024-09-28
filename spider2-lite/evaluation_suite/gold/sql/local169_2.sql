WITH RECURSIVE generate_series AS (
    SELECT 
        0 AS period
    UNION ALL
    SELECT 
        period + 1
    FROM 
        generate_series
    WHERE 
        period < 20
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
)
SELECT 
    d.first_state AS state,
    COUNT(DISTINCT d.id_bioguide) AS count_
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
WHERE 
    g.gender = 'F'  
GROUP BY 
    d.first_state
ORDER BY 
    COUNT(DISTINCT d.id_bioguide) DESC  
LIMIT 1;