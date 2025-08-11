with product_and_quatity AS (
    SELECT 
        DISTINCT v2ProductName AS other_purchased_products,
        SUM(productQuantity) AS quatity
    FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
        UNNEST(hits) AS hits,
        UNNEST(hits.product) AS product
    WHERE
        _table_suffix BETWEEN '0701' AND '0731'
        AND NOT REGEXP_CONTAINS(LOWER(v2ProductName), 'youtube')
        AND fullVisitorID IN (
            SELECT 
            DISTINCT fullVisitorId
            FROM
                `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
                UNNEST(hits) AS hits,
                UNNEST(hits.product) AS product
            WHERE
                _table_suffix BETWEEN '0701' AND '0731'
                AND REGEXP_CONTAINS(LOWER(v2ProductName), 'youtube')
        )
    GROUP BY v2ProductName
)
SELECT other_purchased_products
FROM product_and_quatity
ORDER BY quatity DESC
LIMIT 1;