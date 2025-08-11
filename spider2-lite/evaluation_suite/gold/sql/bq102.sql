WITH gene_region AS (
  SELECT 
    MIN(start_position) AS start_pos, 
    MAX(end_position) AS end_pos
  FROM `bigquery-public-data.gnomAD.v2_1_1_genomes__chr17` AS main_table
  WHERE EXISTS (
    SELECT 1 
    FROM UNNEST(main_table.alternate_bases) AS alternate_bases
    WHERE EXISTS (
      SELECT 1 
      FROM UNNEST(alternate_bases.vep) AS vep
      WHERE vep.SYMBOL = 'BRCA1'
    )
  )
)


SELECT 
  DISTINCT start_position
FROM `bigquery-public-data.gnomAD.v2_1_1_genomes__chr17` AS main_table,
     UNNEST(main_table.alternate_bases) AS alternate_bases,
     UNNEST(alternate_bases.vep) AS vep,
     gene_region
WHERE main_table.start_position >= gene_region.start_pos
  AND main_table.start_position <= gene_region.end_pos
  AND REGEXP_CONTAINS(vep.Consequence, r"missense_variant")
  AND reference_bases = "C"
  AND alternate_bases.alt = "T"
