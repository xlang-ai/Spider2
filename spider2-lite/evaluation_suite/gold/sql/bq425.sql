SELECT *
  FROM (
  SELECT
  molregno,
  comp.company,
  prod.trade_name,
  prod.approval_date,
  ROW_NUMBER() OVER(PARTITION BY molregno ORDER BY PARSE_DATE('%Y-%m-%d', prod.approval_date) DESC) rn
  FROM bigquery-public-data.ebi_chembl.compound_records_23 AS cmpd_rec
  JOIN bigquery-public-data.ebi_chembl.molecule_synonyms_23 AS ms USING (molregno)
  JOIN bigquery-public-data.ebi_chembl.research_companies_23 AS comp USING (res_stem_id)
  JOIN bigquery-public-data.ebi_chembl.formulations_23 AS form USING (molregno)
  JOIN bigquery-public-data.ebi_chembl.products_23 AS prod USING (product_id)
  ) as subq
 WHERE rn = 1 AND company = 'SanofiAventis'