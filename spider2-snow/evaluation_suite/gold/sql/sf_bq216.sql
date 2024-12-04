WITH patents_sample AS (
    SELECT 
        "publication_number", 
        "application_number"
    FROM
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
    WHERE
        "publication_number" = 'US-9741766-B2'
),
flattened_t5 AS (
    SELECT
        t5."publication_number",
        f.value AS element_value,
        f.index AS pos
    FROM
        PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB t5,
        LATERAL FLATTEN(input => t5."embedding_v1") AS f
),
flattened_t6 AS (
    SELECT
        t6."publication_number",
        f.value AS element_value,
        f.index AS pos
    FROM
        PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB t6,
        LATERAL FLATTEN(input => t6."embedding_v1") AS f
),
similarities AS (
    SELECT
        t1."publication_number" AS base_publication_number,
        t4."publication_number" AS similar_publication_number,
        SUM(ft5.element_value * ft6.element_value) AS similarity
    FROM
        (SELECT * FROM patents_sample LIMIT 1) t1
    LEFT JOIN (
        SELECT 
            x3."publication_number",
            EXTRACT(YEAR, TO_DATE(CAST(x3."filing_date" AS STRING), 'YYYYMMDD')) AS focal_filing_year
        FROM 
            PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS x3
        WHERE 
            x3."filing_date" != 0
    ) t3 ON t3."publication_number" = t1."publication_number"
    LEFT JOIN (
        SELECT 
            x4."publication_number",
            EXTRACT(YEAR, TO_DATE(CAST(x4."filing_date" AS STRING), 'YYYYMMDD')) AS filing_year
        FROM 
            PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS x4
        WHERE 
            x4."filing_date" != 0
    ) t4 ON
        t4."publication_number" != t1."publication_number"
        AND t3.focal_filing_year = t4.filing_year
    LEFT JOIN flattened_t5 AS ft5 ON ft5."publication_number" = t1."publication_number"
    LEFT JOIN flattened_t6 AS ft6 ON ft6."publication_number" = t4."publication_number"
    AND ft5.pos = ft6.pos  -- Align vector positions
    GROUP BY
        t1."publication_number", t4."publication_number"
)
SELECT
    s.similar_publication_number,
    s.similarity
FROM (
    SELECT
        s.*,
        ROW_NUMBER() OVER (PARTITION BY s.base_publication_number ORDER BY s.similarity DESC) AS seqnum
    FROM
        similarities s
) s
WHERE
    seqnum <= 5;
