WITH "filings" AS (
    SELECT
        "patent_id",
        MIN(TRY_TO_DATE("date")) AS "filing_date"
    FROM "PATENTSVIEW"."PATENTSVIEW"."APPLICATION"
    WHERE "country" = 'US'
      AND TRY_TO_DATE("date") IS NOT NULL
    GROUP BY "patent_id"
),
"qualified_cpc" AS (
    SELECT DISTINCT
        "patent_id"
    FROM "PATENTSVIEW"."PATENTSVIEW"."CPC_CURRENT"
    WHERE "subsection_id" IN ('C05','C06','C07','C08','C09','C10','C11','C12','C13')
       OR "group_id" IN ('A01G','A01H','A61K','A61P','A61Q','B01F','B01J','B81B','B82B','B82Y','G01N','G16H')
),
"base_pats" AS (
    SELECT DISTINCT
        p."id" AS "patent_id",
        p."title",
        p."abstract",
        TRY_TO_DATE(p."date") AS "publication_date",
        f."filing_date"
    FROM "PATENTSVIEW"."PATENTSVIEW"."PATENT" p
    JOIN "filings" f ON p."id" = f."patent_id"
    JOIN "qualified_cpc" qc ON p."id" = qc."patent_id"
    WHERE p."country" = 'US'
      AND f."filing_date" BETWEEN TO_DATE('2014-01-01') AND TO_DATE('2014-02-01')
      AND TRY_TO_DATE(p."date") IS NOT NULL
),
"backward_counts" AS (
    SELECT
        bc."patent_id",
        COUNT(DISTINCT bc."citation_id") AS "backward_citations"
    FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" bc
    JOIN "base_pats" b ON bc."patent_id" = b."patent_id"
    WHERE TRY_TO_DATE(bc."date") IS NOT NULL
      AND TRY_TO_DATE(bc."date") < b."filing_date"
    GROUP BY bc."patent_id"
),
"forward_counts" AS (
    SELECT
        fc."citation_id" AS "patent_id",
        COUNT(DISTINCT fc."patent_id") AS "forward_citations"
    FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" fc
    JOIN "base_pats" b ON fc."citation_id" = b."patent_id"
    JOIN "PATENTSVIEW"."PATENTSVIEW"."PATENT" pc ON pc."id" = fc."patent_id"
    WHERE TRY_TO_DATE(pc."date") IS NOT NULL
      AND TRY_TO_DATE(pc."date") >= b."publication_date"
      AND TRY_TO_DATE(pc."date") <= DATEADD(year, 5, b."publication_date")
    GROUP BY fc."citation_id"
)
SELECT
    b."title",
    b."abstract",
    b."publication_date",
    COALESCE(back."backward_citations", 0) AS "backward_citation_count",
    COALESCE(fwd."forward_citations", 0) AS "forward_citation_count"
FROM "base_pats" b
LEFT JOIN "backward_counts" back ON back."patent_id" = b."patent_id"
LEFT JOIN "forward_counts" fwd ON fwd."patent_id" = b."patent_id"
ORDER BY b."publication_date", b."title"