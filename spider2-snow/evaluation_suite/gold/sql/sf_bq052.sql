SELECT
    app."patent_id" AS "patent_id",
    patent."title",
    app."date" AS "application_date",
    filterData."bkwdCitations_1",
    filterData."fwrdCitations_1",
    summary."text" AS "summary_text"
FROM
    PATENTSVIEW.PATENTSVIEW.BRF_SUM_TEXT AS summary
JOIN
    PATENTSVIEW.PATENTSVIEW.PATENT AS patent
    ON summary."patent_id" = patent."id"
JOIN
    PATENTSVIEW.PATENTSVIEW.APPLICATION AS app
    ON app."patent_id" = summary."patent_id"
JOIN (
    SELECT DISTINCT
        cpc."patent_id",
        IFNULL(citation_1."bkwdCitations_1", 0) AS "bkwdCitations_1",
        IFNULL(citation_1."fwrdCitations_1", 0) AS "fwrdCitations_1"
    FROM
        PATENTSVIEW.PATENTSVIEW.CPC_CURRENT AS cpc
    JOIN (
        SELECT
            b."patent_id",
            b."bkwdCitations_1",
            f."fwrdCitations_1"
        FROM (
            SELECT
                cited."patent_id",
                COUNT(*) AS "fwrdCitations_1"
            FROM
                PATENTSVIEW.PATENTSVIEW.USPATENTCITATION AS cited
            JOIN
                PATENTSVIEW.PATENTSVIEW.APPLICATION AS apps
                ON cited."patent_id" = apps."patent_id"
            WHERE
                apps."country" = 'US'
                AND cited."date" >= apps."date"
                AND TRY_CAST(cited."date" AS DATE) <= DATEADD(MONTH, 1, TRY_CAST(apps."date" AS DATE)) -- Citation within 1 month
            GROUP BY
                cited."patent_id"
        ) AS f
        JOIN (
            SELECT
                cited."patent_id",
                COUNT(*) AS "bkwdCitations_1"
            FROM
                PATENTSVIEW.PATENTSVIEW.USPATENTCITATION AS cited
            JOIN
                PATENTSVIEW.PATENTSVIEW.APPLICATION AS apps
                ON cited."patent_id" = apps."patent_id"
            WHERE
                apps."country" = 'US'
                AND cited."date" < apps."date"
                AND TRY_CAST(cited."date" AS DATE) >= DATEADD(MONTH, -1, TRY_CAST(apps."date" AS DATE)) -- Citation within 1 month before
            GROUP BY
                cited."patent_id"
        ) AS b
        ON b."patent_id" = f."patent_id"
        WHERE
            b."bkwdCitations_1" IS NOT NULL
            AND f."fwrdCitations_1" IS NOT NULL
            AND (b."bkwdCitations_1" > 0 OR f."fwrdCitations_1" > 0)
    ) AS citation_1
    ON cpc."patent_id" = citation_1."patent_id"
    WHERE
        cpc."subsection_id" = 'C05'
        OR cpc."group_id" = 'A01G'
) AS filterData
ON app."patent_id" = filterData."patent_id"
ORDER BY app."date";
