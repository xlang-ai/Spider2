WITH patents_sample AS (
    SELECT
        t1."publication_number",
        t1."application_number"
    FROM
        PATENTS.PATENTS.PUBLICATIONS t1
    WHERE
        TO_DATE(
            CASE
                WHEN t1."grant_date" != 0 THEN TO_CHAR(t1."grant_date")
                ELSE NULL
            END, 
            'YYYYMMDD'
        ) BETWEEN TO_DATE('20100101', 'YYYYMMDD') AND TO_DATE('20101231', 'YYYYMMDD')
),
forward_citation AS (
    SELECT
        patents_sample."publication_number",
        COUNT(DISTINCT t3."citing_application_number") AS "forward_citations"
    FROM
        patents_sample
        LEFT JOIN (
            SELECT
                x2."publication_number",
                TO_DATE(
                    CASE
                        WHEN x2."filing_date" != 0 THEN TO_CHAR(x2."filing_date")
                        ELSE NULL
                    END,
                    'YYYYMMDD'
                ) AS "filing_date"
            FROM
                PATENTS.PATENTS.PUBLICATIONS x2
            WHERE
                x2."filing_date" != 0
        ) t2
            ON t2."publication_number" = patents_sample."publication_number"
        LEFT JOIN (
            SELECT
                x3."publication_number" AS "citing_publication_number",
                x3."application_number" AS "citing_application_number",
                TO_DATE(
                    CASE
                        WHEN x3."filing_date" != 0 THEN TO_CHAR(x3."filing_date")
                        ELSE NULL
                    END,
                    'YYYYMMDD'
                ) AS "joined_filing_date",
                cite.value:"publication_number"::STRING AS "cited_publication_number"
            FROM
                PATENTS.PATENTS.PUBLICATIONS x3,
                LATERAL FLATTEN(INPUT => x3."citation") cite
            WHERE
                x3."filing_date" != 0
        ) t3
            ON patents_sample."publication_number" = t3."cited_publication_number"
            AND t3."joined_filing_date" BETWEEN t2."filing_date" AND DATEADD(YEAR, 10, t2."filing_date")
    GROUP BY
        patents_sample."publication_number"
)

SELECT
    COUNT(*)
FROM
    forward_citation
WHERE
    "forward_citations" = 1;
