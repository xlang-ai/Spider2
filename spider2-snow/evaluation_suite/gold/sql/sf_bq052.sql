WITH CpcFilteredPatents AS (
    SELECT DISTINCT
        p."id",
        p."title",
        p."abstract"
    FROM "PATENTSVIEW"."PATENTSVIEW"."PATENT" AS p
    JOIN "PATENTSVIEW"."PATENTSVIEW"."CPC_CURRENT" AS cpc ON p."id" = cpc."patent_id"
    WHERE p."country" = 'US' AND (cpc."subsection_id" = 'C05' OR cpc."group_id" = 'A01G')
)
SELECT
    cfp."id" AS patent_id,
    cfp."title",
    core_app."date" AS application_date,
    COUNT(DISTINCT CASE
        WHEN citing_app."date"::DATE >= DATEADD(month, -1, core_app."date"::DATE) AND citing_app."date"::DATE < core_app."date"::DATE
        THEN usc."patent_id"
        ELSE NULL
    END) AS num_backward_citations,
    COUNT(DISTINCT CASE
        WHEN citing_app."date"::DATE > core_app."date"::DATE AND citing_app."date"::DATE <= DATEADD(month, 1, core_app."date"::DATE)
        THEN usc."patent_id"
        ELSE NULL
    END) AS num_forward_citations,
    cfp."abstract"
FROM CpcFilteredPatents AS cfp
JOIN "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS core_app ON cfp."id" = core_app."patent_id"
LEFT JOIN "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" AS usc ON cfp."id" = usc."citation_id"
LEFT JOIN "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS citing_app ON usc."patent_id" = citing_app."patent_id"
GROUP BY
    cfp."id",
    cfp."title",
    core_app."date",
    cfp."abstract"
HAVING
    num_backward_citations > 0 OR num_forward_citations > 0
ORDER BY
    application_date