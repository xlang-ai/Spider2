SELECT
    citing_assignee,
    cpcdef.titleFull as cpc_title
FROM (
    SELECT
        pubs.publication_number AS citing_publication_number,
        cite.publication_number AS cited_publication_number,
        citing_assignee_s.name AS citing_assignee,
        SUBSTR(cpcs.code, 0, 4) AS citing_cpc_subclass
    FROM 
        `spider2-public-data.patents.publications` AS pubs,
        UNNEST(citation) AS cite,
        UNNEST(assignee_harmonized) AS citing_assignee_s,
        UNNEST(cpc) AS cpcs
    WHERE
        cpcs.first = TRUE
    ) AS pubs
    JOIN (
        SELECT
            publication_number AS cited_publication_number,
            cited_assignee_s.name AS cited_assignee
        FROM
            `spider2-public-data.patents.publications`,
            UNNEST(assignee_harmonized) AS cited_assignee_s
    ) AS refs
    ON
        pubs.cited_publication_number = refs.cited_publication_number
    JOIN
        `spider2-public-data.patents.cpc_definition` AS cpcdef
    ON cpcdef.symbol = citing_cpc_subclass
WHERE
    cited_assignee = "DENSO CORP"
    AND citing_assignee != "DENSO CORP"
GROUP BY
    citing_assignee, cpcdef.titleFull
ORDER BY 
    COUNT(*)
DESC LIMIT 1