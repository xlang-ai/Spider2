WITH target_embedding_flat AS (
  SELECT
    f.index,
    f.value::FLOAT AS value
  FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB" AS t,
  LATERAL FLATTEN(input => t."embedding_v1") AS f
  WHERE t."publication_number" = 'US-9741766-B2'
),
candidate_patents_with_year AS (
  SELECT
    p."publication_number",
    e."embedding_v1"
  FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" AS p
  JOIN "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB" AS e ON p."publication_number" = e."publication_number"
  WHERE p."filing_date" != 0
    AND EXTRACT(YEAR FROM TO_DATE(CAST(p."filing_date" AS VARCHAR), 'YYYYMMDD')) = 2016
    AND p."publication_number" != 'US-9741766-B2'
),
candidate_embeddings_flat AS (
  SELECT
    c."publication_number",
    f.index,
    f.value::FLOAT AS value
  FROM candidate_patents_with_year AS c,
  LATERAL FLATTEN(input => c."embedding_v1") AS f
)
SELECT
  c."publication_number"
FROM candidate_embeddings_flat AS c
JOIN target_embedding_flat AS t ON c.index = t.index
GROUP BY c."publication_number"
ORDER BY SUM(c.value * t.value) DESC
LIMIT 5