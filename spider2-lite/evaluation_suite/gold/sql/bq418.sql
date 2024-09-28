WITH
    target_list_query AS (
      SELECT DISTINCT inter.target_uniprotID
      FROM `isb-cgc-bq.targetome_versioned.interactions_v1` AS inter
      INNER JOIN `isb-cgc-bq.targetome_versioned.drug_synonyms_v1` AS drugsyn
        ON inter.drugID = drugsyn.drugID 
      INNER JOIN `isb-cgc-bq.targetome_versioned.experiments_v1` AS exp
        ON inter.expID = exp.expID 
      INNER JOIN `isb-cgc-bq.reactome_versioned.physical_entity_v77` AS pe
        ON inter.target_uniprotID = pe.uniprot_id
      WHERE
        LOWER(drugsyn.synonym) = LOWER('sorafenib')
        AND exp.exp_assayValueMedian <= 100
        AND (exp.exp_assayValueLow <= 100 OR exp.exp_assayValueLow IS NULL)
        AND (exp.exp_assayValueHigh <= 100 OR exp.exp_assayValueHigh IS NULL)
        AND inter.targetSpecies = 'Homo sapiens'
    ),
    
    target_pp_query AS (
      SELECT
        COUNT(DISTINCT target_list_query.target_uniprotID) AS num_targets,
        pathway.stable_id
      FROM target_list_query
      INNER JOIN `isb-cgc-bq.reactome_versioned.physical_entity_v77` AS pe
        ON target_list_query.target_uniprotID = pe.uniprot_id
      INNER JOIN `isb-cgc-bq.reactome_versioned.pe_to_pathway_v77` AS pe2pathway
        ON pe.stable_id = pe2pathway.pe_stable_id
      INNER JOIN `isb-cgc-bq.reactome_versioned.pathway_v77` AS pathway
        ON pe2pathway.pathway_stable_id = pathway.stable_id
      WHERE pe2pathway.evidence_code = 'TAS'
      GROUP BY pathway.stable_id
      ORDER BY num_targets DESC
    ),
    
    not_target_list_query AS (
      SELECT DISTINCT inter.target_uniprotID AS target_uniprotID
      FROM `isb-cgc-bq.targetome_versioned.interactions_v1` AS inter
      WHERE inter.targetSpecies = 'Homo sapiens'
        AND inter.target_uniprotID NOT IN (SELECT target_uniprotID FROM target_list_query)
    ),
    
    not_target_pp_query AS (
      SELECT
        COUNT(DISTINCT not_target_list_query.target_uniprotID) AS num_not_targets,
        pathway.stable_id
      FROM not_target_list_query
      INNER JOIN `isb-cgc-bq.reactome_versioned.physical_entity_v77` AS pe
        ON not_target_list_query.target_uniprotID = pe.uniprot_id
      INNER JOIN `isb-cgc-bq.reactome_versioned.pe_to_pathway_v77` AS pe2pathway
        ON pe.stable_id = pe2pathway.pe_stable_id
      INNER JOIN `isb-cgc-bq.reactome_versioned.pathway_v77` AS pathway
        ON pe2pathway.pathway_stable_id = pathway.stable_id
      WHERE pe2pathway.evidence_code = 'TAS'
      GROUP BY pathway.stable_id
      ORDER BY num_not_targets DESC
    ),
    
    target_count_query AS (
      SELECT
        target_count,
        not_target_count,
        target_count + not_target_count AS total_count
      FROM 
        (SELECT COUNT(*) AS target_count FROM target_list_query),
        (SELECT COUNT(*) AS not_target_count FROM not_target_list_query)
    ),
    
    observed_query AS (
      SELECT
        target_pp_query.num_targets AS in_target_in_pathway,
        not_target_pp_query.num_not_targets AS not_target_in_pathway,
        target_count_query.target_count - target_pp_query.num_targets AS in_target_not_pathway,
        target_count_query.not_target_count - not_target_pp_query.num_not_targets AS not_target_not_pathway,
        target_pp_query.stable_id
      FROM target_pp_query, target_count_query
      INNER JOIN not_target_pp_query
        ON target_pp_query.stable_id = not_target_pp_query.stable_id
    ),
    
    sum_query AS (
      SELECT
        observed_query.in_target_in_pathway + observed_query.not_target_in_pathway AS pathway_total,
        observed_query.in_target_not_pathway + observed_query.not_target_not_pathway AS not_pathway_total,
        observed_query.in_target_in_pathway + observed_query.in_target_not_pathway AS target_total,
        observed_query.not_target_in_pathway + observed_query.not_target_not_pathway AS not_target_total,
        observed_query.stable_id
      FROM observed_query
    ),
    
    expected_query AS (
      SELECT 
        sum_query.target_total * sum_query.pathway_total / target_count_query.total_count AS exp_in_target_in_pathway,
        sum_query.not_target_total * sum_query.pathway_total / target_count_query.total_count AS exp_not_target_in_pathway,
        sum_query.target_total * sum_query.not_pathway_total / target_count_query.total_count AS exp_in_target_not_pathway,
        sum_query.not_target_total * sum_query.not_pathway_total / target_count_query.total_count AS exp_not_target_not_pathway,
        sum_query.stable_id
      FROM sum_query, target_count_query
    ),
    
    chi_squared_query AS (
      SELECT
        POW(ABS(observed_query.in_target_in_pathway - expected_query.exp_in_target_in_pathway) - 0.5, 2) / expected_query.exp_in_target_in_pathway 
        + POW(ABS(observed_query.not_target_in_pathway - expected_query.exp_not_target_in_pathway) - 0.5, 2) / expected_query.exp_not_target_in_pathway
        + POW(ABS(observed_query.in_target_not_pathway - expected_query.exp_in_target_not_pathway) - 0.5, 2) / expected_query.exp_in_target_not_pathway
        + POW(ABS(observed_query.not_target_not_pathway - expected_query.exp_not_target_not_pathway) - 0.5, 2) / expected_query.exp_not_target_not_pathway
        AS chi_squared_stat,
        observed_query.stable_id
      FROM observed_query
      INNER JOIN expected_query
        ON observed_query.stable_id = expected_query.stable_id
    )
    
SELECT
  chi_squared_query.stable_id,
  observed_query.in_target_in_pathway,
  observed_query.in_target_not_pathway,
  observed_query.not_target_in_pathway,
  observed_query.not_target_not_pathway,
  chi_squared_query.chi_squared_stat
FROM chi_squared_query
INNER JOIN observed_query
  ON chi_squared_query.stable_id = observed_query.stable_id
INNER JOIN `isb-cgc-bq.reactome_versioned.pathway_v77` AS pathway
  ON chi_squared_query.stable_id = pathway.stable_id
WHERE pathway.lowest_level = TRUE
ORDER BY chi_squared_stat DESC
LIMIT 3;
