-- Question: For each loss year from 2010 through 2019,
-- return the total building damage amounts and total contents damage amounts
-- for NFIP claims where the NFIP community name is exactly 'City Of New York'.
--
-- Assumptions / reasoning (per guidelines):
-- 1. Use only the FEMA_NATIONAL_FLOOD_INSURANCE_PROGRAM_CLAIM_INDEX table because
--    it already contains the required fields (NFIP community name, date of loss,
--    building damage amount, contents damage amount).
-- 2. Filter exactly on "NFIP_COMMUNITY_NAME" = 'City Of New York' (case-sensitive
--    equality as in probes) without adding extra communities.
-- 3. Limit to years 2010–2019 inclusive via EXTRACT(year FROM "DATE_OF_LOSS").
-- 4. Aggregate with SUM which automatically ignores NULLs (no additional NULL handling).
-- 5. Group by the extracted year and order ascending for readability.

SELECT
    EXTRACT(year FROM "DATE_OF_LOSS") AS "YEAR_OF_LOSS",
    SUM("BUILDING_DAMAGE_AMOUNT")  AS "total_building_damage_amount",
    SUM("CONTENTS_DAMAGE_AMOUNT")  AS "total_contents_damage_amount"
FROM "WEATHER__ENVIRONMENT"."CYBERSYN"."FEMA_NATIONAL_FLOOD_INSURANCE_PROGRAM_CLAIM_INDEX"
WHERE "NFIP_COMMUNITY_NAME" = 'City Of New York'
  AND "DATE_OF_LOSS" IS NOT NULL
  AND EXTRACT(year FROM "DATE_OF_LOSS") BETWEEN 2010 AND 2019
GROUP BY EXTRACT(year FROM "DATE_OF_LOSS")
ORDER BY "YEAR_OF_LOSS";