WITH category_payments AS (
  SELECT
    final.product_category_name AS Category_Name,
    CASE MAX(final.Credit_Card_Payment, final.Boleto_Payment, final.Voucher_Payment, final.Debit_Card_Payment, final.Not_defined_Payment)
      WHEN final.Credit_Card_Payment THEN 'Credit_Card_Payment'
      WHEN final.Boleto_Payment THEN 'Boleto_Payment'
      WHEN final.Voucher_Payment THEN 'Voucher_Payment'
      WHEN final.Debit_Card_Payment THEN 'Debit_Card_Payment'
      WHEN final.Not_defined_Payment THEN 'Not_defined_Payment'
    END AS Preferred_option,
    MAX(final.Credit_Card_Payment, final.Boleto_Payment, final.Voucher_Payment, final.Debit_Card_Payment, final.Not_defined_Payment) AS Total_Payments
  FROM
    (SELECT
      result.product_category_name,
      SUM(result.Credit_Card_Payment) AS Credit_Card_Payment,
      SUM(result.Boleto_Payment) AS Boleto_Payment,
      SUM(result.Voucher_Payment) AS Voucher_Payment,
      SUM(result.Debit_Card_Payment) AS Debit_Card_Payment,
      SUM(result.Not_defined_Payment) AS Not_defined_Payment
    FROM (
      SELECT
        raw.product_category_name,
        SUM(CASE WHEN raw.payment_type = 'credit_card' THEN 1 ELSE 0 END) AS Credit_Card_Payment,
        SUM(CASE WHEN raw.payment_type = 'boleto' THEN 1 ELSE 0 END) AS Boleto_Payment,
        SUM(CASE WHEN raw.payment_type = 'voucher' THEN 1 ELSE 0 END) AS Voucher_Payment,
        SUM(CASE WHEN raw.payment_type = 'debit_card' THEN 1 ELSE 0 END) AS Debit_Card_Payment,
        SUM(CASE WHEN raw.payment_type = 'not_defined' THEN 1 ELSE 0 END) AS Not_defined_Payment
      FROM (
        SELECT
          pd.product_category_name,
          p.order_id,
          p.payment_type
        FROM olist_order_payments p
        JOIN olist_orders o ON o.order_id = p.order_id
        JOIN olist_order_items i ON i.order_id = o.order_id
        JOIN olist_products_dataset pd ON i.product_id = pd.product_id
        GROUP BY 1, 2, 3
      ) raw
      GROUP BY 1
      ORDER BY 1 ASC
    ) result
    GROUP BY 1
  ) final
  GROUP BY 1
)

SELECT AVG(Total_Payments) AS Average_Most_Used_Payment_Count
FROM category_payments;