WITH patents_sample AS (
SELECT 
  t1.publication_number, 
  t1.application_number 
FROM 
  PATENTS.PATENTS.PUBLICATIONS t1 
WHERE 
  grant_date between 20100101 AND 20101231
),
Forward_citation AS (
     SELECT
     DISTINCT patents_sample.publication_number,
     COUNT(DISTINCT t3.citing_application_number) AS forward_citations
     FROM
     patents_sample
     LEFT JOIN (
     SELECT
     x2.publication_number,
     PARSE_DATE('%Y%m%d', CAST(x2.filing_date AS STRING)) AS filing_date
     FROM
     `patents-public-data.patents.publications` x2
     WHERE
     x2.filing_date != 0) t2
     ON
     t2.publication_number = patents_sample.publication_number
     LEFT JOIN (
     SELECT
     x3.publication_number AS citing_publication_number,
     x3.application_number AS citing_application_number,
     PARSE_DATE('%Y%m%d', CAST(x3.filing_date AS STRING)) AS joined_filing_date,
     citation_u.publication_number AS cited_publication_number
     FROM
     PATENTS.PATENTS.PUBLICATIONS x3,
     UNNEST(citation) AS citation_u
     WHERE
     x3.filing_date!=0) t3
     ON
     patents_sample.publication_number = t3.cited_publication_number
     AND t3.joined_filing_date BETWEEN t2.filing_date
     AND DATE_ADD(t2.filing_date, INTERVAL 10 YEAR)
     GROUP BY
     patents_sample.publication_number
)

SELECT 
COUNT(*)
FROM
     Forward_citation
WHERE forward_citations=1
