WITH bottom_five_cities AS (
    SELECT 
        C."customer_city",
        SUM(CAST(P."payment_value" AS DOUBLE)) AS "Total_Payment_By_Customers",
        COUNT(O."order_id") AS "Total_Number_Of_Orders"
    FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS C
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS O ON C."customer_id" = O."customer_id"
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS P ON O."order_id" = P."order_id"
    WHERE O."order_status" = 'delivered'
    GROUP BY C."customer_city"
    ORDER BY "Total_Payment_By_Customers" ASC
    LIMIT 5
)
SELECT 
    AVG("Total_Payment_By_Customers") AS "Average_Total_Payment",
    AVG("Total_Number_Of_Orders") AS "Average_Total_Orders"
FROM bottom_five_cities;