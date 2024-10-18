WITH
  family_list AS (
    SELECT
      family_id,
      COUNT(publication_number) AS publication_number_count
    FROM
      `spider2-public-data.patents_google.publications`
    GROUP BY
      family_id
  ),
  most_published_family AS (
    SELECT
      family_id
    FROM
      family_list
    WHERE family_id != '-1'
    ORDER BY
      publication_number_count DESC
    LIMIT 1
  ),
  publications_with_abstracts AS (
    SELECT
      p.family_id,
      gpr.abstract
    FROM
      `spider2-public-data.patents_google.abs_and_emb` gpr
    JOIN
      `spider2-public-data.patents_google.publications` p
    ON
      p.publication_number = gpr.publication_number
    WHERE
      gpr.abstract IS NOT NULL AND gpr.abstract != ''
  ),
  abstracts_from_top_family AS (
    SELECT
      fwa.abstract
    FROM
      publications_with_abstracts fwa
    JOIN
      most_published_family mpf
    ON
      fwa.family_id = mpf.family_id
  )
SELECT
  abstract
FROM
  abstracts_from_top_family;


