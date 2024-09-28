WITH top_industry AS
(
    SELECT i.industry
    FROM companies_industries AS i
    INNER JOIN companies_dates AS d
        ON i.company_id = d.company_id
    WHERE strftime('%Y', d.date_joined) IN ('2019', '2020', '2021')
    GROUP BY i.industry
    ORDER BY COUNT(*) DESC
    LIMIT 1
),

yearly_counts AS
(
    SELECT strftime('%Y', d.date_joined) AS year,
           COUNT(*) AS num_unicorns
    FROM companies_industries AS i
    INNER JOIN companies_dates AS d
        ON i.company_id = d.company_id
    WHERE strftime('%Y', d.date_joined) IN ('2019', '2020', '2021')
      AND i.industry = (SELECT industry FROM top_industry)
    GROUP BY year
)

SELECT ROUND(AVG(num_unicorns), 2) AS average_new_unicorns
FROM yearly_counts;