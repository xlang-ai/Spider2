# GA360 - eCommerce Action Type

| Action Type                    | hits.eCommerceAction.action_type Value |
| ------------------------------ | -------------------------------------- |
| Click through of product lists | 1                                      |
| Product detail views           | 2                                      |
| Add product(s) to cart         | 3                                      |
| Remove product(s) from cart    | 4                                      |
| Check out                      | 5                                      |
| Completed purchase             | 6                                      |
| Refund of purchase             | 7                                      |
| Checkout options               | 8                                      |
| Unknown                        | 0                                      |

Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a "product in list view").

**Example query to calculate number of products in list views**:
SELECT
COUNT(hits.product.v2ProductName)
FROM [foo-160803:123456789.ga_sessions_20170101]
WHERE hits.product.isImpression == TRUE

**Example query to calculate number of products in detailed view**:
SELECT
COUNT(hits.product.v2ProductName),
FROM
[foo-160803:123456789.ga_sessions_20170101]
WHERE
hits.ecommerceaction.action_type = '2'
AND ( BOOLEAN(hits.product.isImpression) IS NULL OR BOOLEAN(hits.product.isImpression) == FALSE )