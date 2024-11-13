WITH big_banks AS (
    SELECT id_rssd
    FROM FINANCE__ECONOMICS.CYBERSYN.financial_institution_timeseries
    WHERE variable = 'ASSET'
      AND date = '2022-12-31'
      AND value > 1E10
)
SELECT name
FROM FINANCE__ECONOMICS.CYBERSYN.financial_institution_timeseries AS ts
INNER JOIN FINANCE__ECONOMICS.CYBERSYN.financial_institution_attributes AS att ON (ts.variable = att.variable)
INNER JOIN FINANCE__ECONOMICS.CYBERSYN.financial_institution_entities AS ent ON (ts.id_rssd = ent.id_rssd)
INNER JOIN big_banks ON (big_banks.id_rssd = ts.id_rssd)
WHERE ts.date = '2022-12-31'
  AND att.variable_name = '% Insured (Estimated)'
  AND att.frequency = 'Quarterly'
  AND ent.is_active = True
ORDER BY (1 - value) DESC
LIMIT 10;