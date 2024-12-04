SELECT
    patent."title",
    patent."abstract",
    app."date" AS publication_date,
    filterData."bkwdCitations",
    filterData."fwrdCitations_5"
FROM
    "PATENTSVIEW"."PATENTSVIEW"."PATENT" AS patent
JOIN
    "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS app
    ON app."patent_id" = patent."id"
JOIN (
    SELECT
        DISTINCT cpc."patent_id",
        IFNULL(citation_5."bkwdCitations", 0) AS "bkwdCitations",
        IFNULL(citation_5."fwrdCitations_5", 0) AS "fwrdCitations_5"
    FROM
        "PATENTSVIEW"."PATENTSVIEW"."CPC_CURRENT" AS cpc
    LEFT JOIN (
        SELECT
            b."patent_id",
            b."bkwdCitations",
            f."fwrdCitations_5"
        FROM (
            SELECT 
                cited."citation_id" AS "patent_id",
                IFNULL(COUNT(*), 0) AS "fwrdCitations_5"
            FROM 
                "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" AS cited
            JOIN
                "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS apps
                ON cited."citation_id" = apps."patent_id"
            WHERE
                apps."country" = 'US'
                AND cited."date" >= apps."date"
                AND TRY_CAST(cited."date" AS DATE) <= DATEADD(YEAR, 5, TRY_CAST(apps."date" AS DATE)) -- 5-year citation window
            GROUP BY 
                cited."citation_id"
        ) AS f
        JOIN (
            SELECT 
                cited."patent_id",
                IFNULL(COUNT(*), 0) AS "bkwdCitations"
            FROM 
                "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" AS cited
            JOIN
                "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS apps
                ON cited."patent_id" = apps."patent_id"
            WHERE
                apps."country" = 'US'
                AND cited."date" < apps."date" -- backward citation count
            GROUP BY 
                cited."patent_id"
        ) AS b
        ON b."patent_id" = f."patent_id"
        WHERE
            b."bkwdCitations" IS NOT NULL
            AND f."fwrdCitations_5" IS NOT NULL
    ) AS citation_5 
    ON cpc."patent_id" = citation_5."patent_id"
    WHERE 
        cpc."subsection_id" IN ('C05', 'C06', 'C07', 'C08', 'C09', 'C10', 'C11', 'C12', 'C13')
        OR cpc."group_id" IN ('A01G', 'A01H', 'A61K', 'A61P', 'A61Q', 'B01F', 'B01J', 'B81B', 'B82B', 'B82Y', 'G01N', 'G16H')
) AS filterData
ON app."patent_id" = filterData."patent_id"
WHERE
    TRY_CAST(app."date" AS DATE) < '2014-02-01' 
    AND TRY_CAST(app."date" AS DATE) >= '2014-01-01';
