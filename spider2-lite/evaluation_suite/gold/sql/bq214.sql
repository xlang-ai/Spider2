WITH patents_sample AS (
    SELECT 
        t1.publication_number, 
        t1.application_number 
    FROM 
        `spider2-public-data.patents_google.publications` t1 
    WHERE 
        country_code = 'US' AND
        grant_date BETWEEN 20100101 AND 20141231 AND
        publication_number LIKE '%B2%'
),

Forward_citation AS (
    SELECT
        DISTINCT patents_sample.publication_number,
        COUNT(DISTINCT t3.citing_application_number) AS forward_citations
    FROM
        patents_sample
    LEFT JOIN (
        SELECT
            x2.publication_number,
            PARSE_DATE('%Y%m%d', CAST(x2.filing_date AS STRING)) AS filing_date
        FROM
            `spider2-public-data.patents_google.publications` x2
        WHERE
            x2.filing_date != 0
    ) t2 ON t2.publication_number = patents_sample.publication_number
    LEFT JOIN (
        SELECT
            x3.publication_number AS citing_publication_number,
            x3.application_number AS citing_application_number,
            PARSE_DATE('%Y%m%d', CAST(x3.filing_date AS STRING)) AS joined_filing_date,
            citation_u.publication_number AS cited_publication_number
        FROM
            `spider2-public-data.patents_google.publications` x3,
            UNNEST(citation) AS citation_u
        WHERE
            x3.filing_date != 0
    ) t3 ON patents_sample.publication_number = t3.cited_publication_number AND
             t3.joined_filing_date BETWEEN t2.filing_date AND DATE_ADD(t2.filing_date, INTERVAL 1 MONTH)
    GROUP BY
        patents_sample.publication_number
),

select_sample AS (
    SELECT 
        publication_number
    FROM
        Forward_citation
    ORDER BY
        forward_citations DESC
    LIMIT 1
),

t AS (
    SELECT
        t1.publication_number,
        t4.publication_number AS similar_publication_number,
        (SELECT SUM(element1 * element2)
         FROM t5.embedding_v1 element1 WITH OFFSET pos
         JOIN t6.embedding_v1 element2 WITH OFFSET pos USING (pos)) AS similarity
    FROM 
        (SELECT * FROM select_sample LIMIT 1) t1
    LEFT JOIN (
        SELECT 
            x3.publication_number,
            EXTRACT(YEAR FROM PARSE_DATE('%Y%m%d', CAST(x3.filing_date AS STRING))) AS focal_filing_year
        FROM 
            `spider2-public-data.patents_google.publications` x3
        WHERE 
            x3.filing_date != 0
    ) t3 ON t3.publication_number = t1.publication_number
    LEFT JOIN (
        SELECT 
            x4.publication_number,
            EXTRACT(YEAR FROM PARSE_DATE('%Y%m%d', CAST(x4.filing_date AS STRING))) AS filing_year
        FROM 
            `spider2-public-data.patents_google.publications` x4
        WHERE 
            x4.filing_date != 0
    ) t4 ON  t4.publication_number != t1.publication_number AND
             t3.focal_filing_year = t4.filing_year
    LEFT JOIN `spider2-public-data.patents_google.abs_and_emb` t5 ON t5.publication_number = t1.publication_number
    LEFT JOIN `spider2-public-data.patents_google.abs_and_emb` t6 ON t6.publication_number = t4.publication_number
    ORDER BY 
        t1.publication_number, similarity DESC
)

SELECT
    t.similar_publication_number
FROM (
    SELECT
        t.*,
        ROW_NUMBER() OVER (PARTITION BY publication_number ORDER BY similarity DESC) AS seqnum
    FROM
        t
) t
WHERE
    seqnum <= 1;