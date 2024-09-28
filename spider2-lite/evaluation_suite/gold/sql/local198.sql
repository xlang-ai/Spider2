WITH tcs AS 
  (
    SELECT 
      c.CustomerID AS customer_id,
      SUM(ii.UnitPrice) AS total_sales
    FROM invoice_items AS ii
    JOIN Invoices AS i ON i.InvoiceID = ii.InvoiceID
    JOIN Customers AS c ON c.CustomerID = i.CustomerID
    GROUP BY c.CustomerID
  ),    
country_sales AS
  (
    SELECT
      c.Country AS country,
      COUNT(c.CustomerID) AS customer_count,
      SUM(tcs.total_sales) AS total_sales
    FROM customers AS c
    JOIN tcs ON tcs.customer_id = c.CustomerID
    GROUP BY c.Country
    HAVING COUNT(c.CustomerID) > 4
  ),  
ranked_sales AS
  (
    SELECT
      country,
      total_sales,
      ROW_NUMBER() OVER (ORDER BY total_sales) AS sales_rank,
      COUNT(*) OVER () AS total_count
    FROM country_sales
  )  
SELECT
  AVG(total_sales) AS median_total_sales
FROM ranked_sales
WHERE sales_rank IN 
  (
    (total_count + 1) / 2,
    (total_count + 2) / 2
  )
ORDER BY total_sales;