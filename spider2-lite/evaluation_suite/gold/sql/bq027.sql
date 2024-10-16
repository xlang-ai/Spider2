WITH patents_sample AS (               -- name of our table
SELECT 
  t1.publication_number, 
  t1.application_number 
FROM 
  `spider2-public-data.patents.publications` t1 
WHERE                                                       -- only consider US patents
  grant_date between 20100101 AND 20181231                               -- grant dates between 2002 and 2006
)

SELECT
  t1.publication_number,
  -- count disctinct application numbers cited by our focal patent
  COUNT(DISTINCT t3.application_number) AS backward_citations
FROM
  patents_sample t1
LEFT OUTER JOIN (
  SELECT
    -- the publication number in the joined table is the citing publication number
    x2.publication_number AS citing_publication_number,
    -- the publication number in the unnested citation record is the cited publication number
    citation_u.publication_number AS cited_publication_number,
    -- the category in the unnested citation record is the category of the cited publication
    citation_u.category AS cited_publication_category
  FROM
    `spider2-public-data.patents.publications` x2,
    UNNEST(citation) AS citation_u ) t2
ON
  t2.citing_publication_number = t1.publication_number
  -- citation category has to contain 'SEA'
  AND CONTAINS_SUBSTR(t2.cited_publication_category, 'SEA')
  -- one more join to publications table to get the application number
LEFT OUTER JOIN
  `spider2-public-data.patents.publications` t3
ON
  t2.cited_publication_number = t3.publication_number
GROUP BY
  t1.publication_number
ORDER BY
  backward_citations DESC