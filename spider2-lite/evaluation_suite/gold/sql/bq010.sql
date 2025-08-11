WITH GET_CUS_ID AS (
    SELECT 
        DISTINCT fullVisitorId as Henley_CUSTOMER_ID
    FROM 
        `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
        UNNEST(hits) AS hits,
        UNNEST(hits.product) as product
    WHERE
        product.v2ProductName = "YouTube Men's Vintage Henley"
        AND product.productRevenue IS NOT NULL
    )

SELECT
    product.v2ProductName AS other_purchased_products
FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` TAB_A 
    RIGHT JOIN GET_CUS_ID
    ON GET_CUS_ID.Henley_CUSTOMER_ID=TAB_A.fullVisitorId,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) as product
WHERE
    TAB_A.fullVisitorId IN (
        SELECT * FROM GET_CUS_ID
    )
    AND product.v2ProductName <> "YouTube Men's Vintage Henley"
    AND product.productRevenue IS NOT NULL
GROUP BY
    product.v2ProductName
ORDER BY
    SUM(product.productQuantity) DESC
LIMIT 1;