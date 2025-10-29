SELECT COUNT(*) AS "num_patents"
FROM (
  SELECT p."publication_number"
  FROM "PATENTS"."PATENTS"."PUBLICATIONS" AS p,
       LATERAL FLATTEN(input => p."claims_localized") AS cl
  WHERE p."country_code" = 'US'
    AND p."kind_code" = 'B2'
    AND p."grant_date" BETWEEN 20080101 AND 20181231
  GROUP BY p."publication_number"
  HAVING SUM(CASE WHEN REGEXP_LIKE(cl.value:"text"::string, '\\bclaim\\b', 'i') THEN 1 ELSE 0 END) = 0
);