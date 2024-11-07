WITH table_a AS(
    SELECT 
        pat_no, claim_no, word_ct
    FROM `patents-public-data.uspto_oce_claims.patent_claims_stats` 
    WHERE ind_flg='1'
), matched_publn AS(
    SELECT
        publication_number,
        claim_no,
        CAST(word_ct AS INT64) AS word_ct  -- Cast word_ct to INT64 if it's stored as a string
    FROM table_a
    INNER JOIN `patents-public-data.uspto_oce_claims.match` USING(pat_no)
), matched_appln AS(
    SELECT
        application_number appln_nr,
        publication_number publn_nr,
        claim_no,
        word_ct
    FROM matched_publn
    INNER JOIN(
        SELECT 
            publication_number, application_number, country_code,
            ROW_NUMBER() OVER(PARTITION BY application_number ORDER BY publication_date ASC) row_num,
            kind_code, publication_date
        FROM `patents-public-data.patents.publications`
    ) USING(publication_number)
    WHERE row_num=1
)

SELECT *
FROM matched_appln
ORDER BY word_ct DESC
LIMIT 100
