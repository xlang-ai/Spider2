WITH patents_sample AS (
  SELECT 
    t1.publication_number,
    claim.text AS claims_text
  FROM 
    spider2-public-data.patents.publications t1,
    UNNEST(t1.claims_localized) AS claim
  WHERE 
    t1.country_code = 'US'
    AND t1.grant_date BETWEEN 20080101 AND 20181231
    AND t1.grant_date != 0
    AND t1.publication_number LIKE '%B2%'
),
Publication_data AS (
  SELECT
    publication_number,
    COUNTIF(claims_text NOT LIKE '%claim%') AS nb_indep_claims
  FROM
    patents_sample
  GROUP BY
    publication_number
)

SELECT COUNT(nb_indep_claims)
FROM Publication_data
WHERE nb_indep_claims != 0