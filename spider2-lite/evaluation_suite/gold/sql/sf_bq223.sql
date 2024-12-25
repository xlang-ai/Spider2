SELECT
    REPLACE(citing_assignee, '"', '') AS citing_assignee,
    cpcdef."titleFull" AS cpc_title,
    COUNT(*) AS number
FROM (
    SELECT
        pubs."publication_number" AS citing_publication_number,
        cite.value:"publication_number" AS cited_publication_number,
        citing_assignee_s.value:"name" AS citing_assignee,
        SUBSTR(cpcs.value:"code", 1, 4) AS citing_cpc_subclass
    FROM 
        PATENTS.PATENTS.PUBLICATIONS AS pubs
    , LATERAL FLATTEN(input => pubs."citation") AS cite
    , LATERAL FLATTEN(input => pubs."assignee_harmonized") AS citing_assignee_s
    , LATERAL FLATTEN(input => pubs."cpc") AS cpcs
    WHERE
        cpcs.value:"first" = TRUE
) AS pubs
JOIN (
    SELECT
        "publication_number" AS cited_publication_number,
        cited_assignee_s.value:"name" AS cited_assignee
    FROM
        PATENTS.PATENTS.PUBLICATIONS
    , LATERAL FLATTEN(input => "assignee_harmonized") AS cited_assignee_s
) AS refs
    ON pubs.cited_publication_number = refs.cited_publication_number
JOIN
    PATENTS.PATENTS.CPC_DEFINITION AS cpcdef
    ON cpcdef."symbol" = pubs.citing_cpc_subclass
WHERE
    refs.cited_assignee = 'DENSO CORP'
    AND pubs.citing_assignee != 'DENSO CORP'
GROUP BY
    citing_assignee, cpcdef."titleFull"
