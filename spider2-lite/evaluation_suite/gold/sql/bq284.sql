SELECT 
  category,
  COUNT(*) AS number_total_by_category,  
  CASE 
    WHEN category = 'tech' THEN 
          (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE (LOWER(body) LIKE '%education%') AND category = 'tech') * 100 /
                (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE category = 'tech')
    WHEN category = 'sport' THEN 
          (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE (LOWER(body) LIKE '%education%') AND category = 'sport') * 100 /
                (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE category = 'sport')
    WHEN category = 'business' THEN 
          (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE (LOWER(body) LIKE '%education%') AND category = 'business') * 100 /
                (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE category = 'business')
    WHEN category = 'politics' THEN 
          (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE (LOWER(body) LIKE '%education%') AND category = 'politics') * 100 /
                (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE category = 'politics')
    WHEN category = 'entertainment' THEN 
          (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE (LOWER(body) LIKE '%education%') AND category = 'entertainment') * 100 /
                (SELECT count(*)
                FROM `bigquery-public-data.bbc_news.fulltext`
                WHERE category = 'entertainment')
  END AS percent_education
FROM `bigquery-public-data.bbc_news.fulltext`
GROUP BY
  category;