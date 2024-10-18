WITH calls AS (
  SELECT
    call.name AS call_set_name,
    alt_offset + 1 AS alt_num,
    (SELECT LOGICAL_AND(gt = 0) FROM UNNEST(call.genotype) gt) AS reference_match_call
  FROM
    `spider2-public-data.human_genome_variants.1000_genomes_phase_3_variants_20150220` v,
    UNNEST(v.call) call, v.alternate_bases alt WITH OFFSET alt_offset
),

compute_sums AS (
  SELECT
    call_set_name,
    SUM(CAST(alt_num = 1 AND reference_match_call AS INT64)) AS hom_RR_count
  FROM calls
  GROUP BY call_set_name
)

SELECT
  call_set_name,
  hom_RR_count
FROM compute_sums
ORDER BY hom_RR_count DESC
LIMIT 5