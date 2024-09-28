WITH RankedProducts AS (
    SELECT
        dp.division,
        fsm.product_code,
        dp.product,
        SUM(fsm.sold_quantity) AS total_sold_quantity,
        ROW_NUMBER() OVER(PARTITION BY dp.division ORDER BY SUM(fsm.sold_quantity) DESC) AS rank_order
    FROM
        hardware_fact_sales_monthly fsm
    JOIN
        hardware_dim_product dp ON fsm.product_code = dp.product_code
    WHERE
        strftime('%Y', fsm.date) = '2021'
    GROUP BY
        dp.division, fsm.product_code, dp.product
),
Top3Products AS (
    SELECT
        division,
        product_code,
        product,
        total_sold_quantity,
        rank_order
    FROM
        RankedProducts
    WHERE
        rank_order <= 3
)
SELECT
    division,
    AVG(total_sold_quantity) AS avg_sold_quantity
FROM
    Top3Products
GROUP BY
    division
ORDER BY
    avg_sold_quantity DESC;
