SELECT
   COALESCE(p.journal.title, p.proceedings_title.preferred, p.book_title.preferred, p.book_series_title.preferred) AS venue,
FROM
   `bigquery-public-data.dimensions_ai_covid19.publications` p
LEFT JOIN
   UNNEST(research_orgs) AS research_orgs_grids
LEFT JOIN
   `bigquery-public-data.dimensions_ai_covid19.grid` grid
ON
   grid.id=research_orgs_grids
WHERE
   EXTRACT(YEAR FROM date_inserted) >= 2021
   AND
   grid.address.city = 'Qianjiang'