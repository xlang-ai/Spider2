WITH temp AS (
  SELECT
    pt.plot_state_code_name AS state_name,
    p.inventory_year AS inventory_year,
    p.state_code AS state_code, 
    -- Calculate area - this replaces the "decode" logic in example from Oracle
    CASE
      WHEN c.proportion_basis = 'MACR' AND p.adjustment_factor_for_the_macroplot > 0 THEN
        (p.expansion_factor * c.condition_proportion_unadjusted * p.adjustment_factor_for_the_macroplot)
      ELSE 0
    END AS macroplot_acres,
    CASE
      WHEN c.proportion_basis = 'SUBP' AND p.adjustment_factor_for_the_subplot > 0 THEN
        (p.expansion_factor * c.condition_proportion_unadjusted * p.adjustment_factor_for_the_subplot)
      ELSE 0
    END AS subplot_acres
  FROM 
    `bigquery-public-data.usfs_fia.condition` c
  JOIN 
    `bigquery-public-data.usfs_fia.plot_tree` pt
      ON pt.plot_sequence_number = c.plot_sequence_number
  JOIN 
    `bigquery-public-data.usfs_fia.population` p
      ON p.plot_sequence_number = pt.plot_sequence_number
  WHERE 
    p.evaluation_type = 'EXPCURR'
    AND c.condition_status_code = 1
    AND p.inventory_year = 2017
)

SELECT *
FROM (
  SELECT 
    state_name,AVG(subplot_acres)
  FROM 
    temp
  GROUP BY 
    state_name
  ORDER BY 
    AVG(subplot_acres) DESC
  LIMIT 1
)
UNION ALL
(
  SELECT 
    state_name,AVG(macroplot_acres)
  FROM 
    temp
  GROUP BY 
    state_name
  ORDER BY 
    AVG(macroplot_acres) DESC
  LIMIT 1
)