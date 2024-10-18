SELECT
    app.patent_id as patent_id,
    patent.title,
    app.date as application_date,
    filterData.bkwdCitations_1,
    filterData.fwrdCitations_1,
    summary.text as summary_text
FROM
    `spider2-public-data.patentsview.brf_sum_text` as summary,
    `spider2-public-data.patentsview.patent` as patent,
    `spider2-public-data.patentsview.application` as app,
    (
        SELECT DISTINCT
            cpc.patent_id,
            IFNULL(citation_1.bkwdCitations_1, 0) as bkwdCitations_1,
            IFNULL(citation_1.fwrdCitations_1, 0) as fwrdCitations_1
        FROM
            `spider2-public-data.patentsview.cpc_current` AS cpc
        JOIN
        (
            SELECT  b.patent_id, b.bkwdCitations_1, f.fwrdCitations_1
            FROM (
                SELECT 
                    cited.patent_id,
                    COUNT(*) as fwrdCitations_1
                FROM 
                    `spider2-public-data.patentsview.uspatentcitation` AS cited,
                    `spider2-public-data.patentsview.application` AS apps
                WHERE
                    apps.country = 'US'
                    AND cited.patent_id = apps.patent_id 
                    AND cited.date >= apps.date
                    AND SAFE_CAST(cited.date AS DATE) <= DATE_ADD(SAFE_CAST(apps.date AS DATE), INTERVAL 1 MONTH)
                GROUP BY 
                    cited.patent_id
            ) AS f,
            (
                SELECT 
                    cited.patent_id,
                    COUNT(*) as bkwdCitations_1
                FROM 
                    `spider2-public-data.patentsview.uspatentcitation` AS cited,
                    `spider2-public-data.patentsview.application` AS apps
                WHERE
                    apps.country = 'US'
                    AND cited.patent_id = apps.patent_id 
                    AND cited.date < apps.date AND SAFE_CAST(cited.date AS DATE) >= DATE_SUB(SAFE_CAST(apps.date AS DATE), INTERVAL 1 MONTH) -- get in one year interval 
                GROUP BY 
                    cited.patent_id
            ) AS b
            WHERE
                b.patent_id = f.patent_id
                AND b.bkwdCitations_1 IS NOT NULL
                AND f.fwrdCitations_1 IS NOT NULL
                AND (b.bkwdCitations_1 > 0 OR f.fwrdCitations_1 > 0)
        ) AS citation_1 
        ON cpc.patent_id=citation_1.patent_id
        WHERE (
            cpc.subsection_id = 'C05'
            OR cpc.group_id = 'A01G'
        )
    ) as filterData
WHERE
    app.patent_id = filterData.patent_id
    AND summary.patent_id = app.patent_id
    AND app.patent_id = patent.id
ORDER BY application_date;