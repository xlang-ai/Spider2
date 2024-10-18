SELECT filterData.fwrdCitations_3
FROM
  `spider2-public-data.patentsview.application` as app,
  (SELECT DISTINCT cpc.patent_id, IFNULL(citation_3.bkwdCitations_3, 0) as bkwdCitations_3, IFNULL(citation_3.fwrdCitations_3, 0) as fwrdCitations_3
  FROM
    `spider2-public-data.patentsview.cpc_current` AS cpc
    LEFT JOIN
    (SELECT  b.patent_id, b.bkwdCitations_3, f.fwrdCitations_3
      FROM 
        (SELECT 
          cited.patent_id,
          COUNT(*) as fwrdCitations_3
          FROM 
          `spider2-public-data.patentsview.uspatentcitation` AS cited,
          `spider2-public-data.patentsview.application` AS apps
        WHERE
          apps.country = 'US'
          AND cited.patent_id = apps.patent_id 
          AND cited.date >= apps.date AND SAFE_CAST(cited.date AS DATE) <= DATE_ADD(SAFE_CAST(apps.date AS DATE), INTERVAL 3 YEAR)
         GROUP BY 
         cited.patent_id) AS f,

       (SELECT 
          cited.patent_id,
          COUNT(*) as bkwdCitations_3
          FROM 
          `spider2-public-data.patentsview.uspatentcitation` AS cited,
          `spider2-public-data.patentsview.application` AS apps
        WHERE
          apps.country = 'US'
          AND cited.patent_id = apps.patent_id 
          AND cited.date < apps.date AND SAFE_CAST(cited.date AS DATE) >= DATE_SUB(SAFE_CAST(apps.date AS DATE), INTERVAL 3 YEAR)
         GROUP BY 
         cited.patent_id) AS b
      WHERE
      b.patent_id = f.patent_id AND b.bkwdCitations_3 IS NOT NULL AND f.fwrdCitations_3 IS NOT NULL) AS citation_3
      ON cpc.patent_id = citation_3.patent_id
      )
  as filterData
  WHERE
  app.patent_id = filterData.patent_id
  ORDER BY filterData.bkwdCitations_3 DESC
  LIMIT 1