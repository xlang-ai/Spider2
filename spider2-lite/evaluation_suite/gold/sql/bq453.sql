SELECT
  reference_name,
  start,
  `END`,
  reference_bases,
  alt,
  vt,
  POW(hom_ref_count - expected_hom_ref_count, 2) / expected_hom_ref_count +
    POW(hom_alt_count - expected_hom_alt_count, 2) / expected_hom_alt_count +
    POW(het_count - expected_het_count, 2) / expected_het_count AS chi_squared_score,
  total_count,
  hom_ref_count,
  expected_hom_ref_count AS expected_hom_ref_count,
  het_count,
  expected_het_count AS expected_het_count,
  hom_alt_count,
  expected_hom_alt_count AS expected_hom_alt_count,
  alt_freq AS alt_freq,
  alt_freq_from_1KG
FROM (
  SELECT
    reference_name,
    start,
    `END`,
    reference_bases,
    alt,
    vt,
    alt_freq_from_1KG,
    hom_ref_freq + (0.5 * het_freq) AS hw_ref_freq,
    1 - (hom_ref_freq + (0.5 * het_freq)) AS alt_freq,
    POW(hom_ref_freq + (0.5 * het_freq), 2) * total_count AS expected_hom_ref_count,
    POW(1 - (hom_ref_freq + (0.5 * het_freq)), 2) * total_count AS expected_hom_alt_count,
    2 * (hom_ref_freq + (0.5 * het_freq)) * (1 - (hom_ref_freq + (0.5 * het_freq))) * total_count AS expected_het_count,
    total_count,
    hom_ref_count,
    het_count,
    hom_alt_count,
    hom_ref_freq,
    het_freq,
    hom_alt_freq
  FROM (
    SELECT
      reference_name,
      start,
      `END`,
      reference_bases,
      STRING_AGG(DISTINCT alternate_base) AS alt,
      vt,
      af AS alt_freq_from_1KG,
      COUNTIF(first_allele IN (0, 1) AND second_allele IN (0, 1)) AS total_count,
      COUNTIF(first_allele = 0 AND second_allele = 0) AS hom_ref_count,
      COUNTIF((first_allele = 0 AND second_allele = 1) OR (first_allele = 1 AND second_allele = 0)) AS het_count,
      COUNTIF(first_allele = 1 AND second_allele = 1) AS hom_alt_count,
      SAFE_DIVIDE(COUNTIF(first_allele = 0 AND second_allele = 0), COUNTIF(first_allele IN (0, 1) AND second_allele IN (0, 1))) AS hom_ref_freq,
      SAFE_DIVIDE(COUNTIF((first_allele = 0 AND second_allele = 1) OR (first_allele = 1 AND second_allele = 0)), COUNTIF(first_allele IN (0, 1) AND second_allele IN (0, 1))) AS het_freq,
      SAFE_DIVIDE(COUNTIF(first_allele = 1 AND second_allele = 1), COUNTIF(first_allele IN (0, 1) AND second_allele IN (0, 1))) AS hom_alt_freq
    FROM (
      SELECT
        reference_name,
        start,
        `END`,
        reference_bases,
        vt,
        af,
        call.call_set_name,
        call.genotype[OFFSET(0)] AS first_allele,
        call.genotype[OFFSET(1)] AS second_allele,
        alternate_base
      FROM
        `spider2-public-data.1000_genomes.variants`,
        UNNEST(call) AS call,
        UNNEST(alternate_bases) AS alternate_base
      WHERE
        reference_name = '17'
        AND start BETWEEN 41196311 AND 41277499
    )
    GROUP BY
      reference_name,
      start,
      `END`,
      reference_bases,
      vt,
      af
  )
)
