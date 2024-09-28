WITH get_extras_count AS (
    WITH RECURSIVE split_extras AS (
        SELECT
            order_id,
            TRIM(SUBSTR(extras, 1, INSTR(extras || ',', ',') - 1)) AS each_extra,
            SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS remaining_extras
        FROM
            pizza_clean_customer_orders
        UNION ALL
        SELECT
            order_id,
            TRIM(SUBSTR(remaining_extras, 1, INSTR(remaining_extras, ',') - 1)) AS each_extra,
            SUBSTR(remaining_extras, INSTR(remaining_extras, ',') + 1)
        FROM
            split_extras
        WHERE
            remaining_extras <> ''
    )
    SELECT
        order_id,
        COUNT(each_extra) AS total_extras
    FROM
        split_extras
    GROUP BY
        order_id
),
calculate_totals AS (
    SELECT
        t1.order_id,
        t1.pizza_id,
        SUM(
            CASE
                WHEN pizza_id = 1 THEN 12
                WHEN pizza_id = 2 THEN 10
            END
        ) AS total_price,
        t3.total_extras
    FROM 
        pizza_clean_customer_orders AS t1
    JOIN
        pizza_clean_runner_orders AS t2 
    ON
        t2.order_id = t1.order_id
    LEFT JOIN
        get_extras_count AS t3
    ON
        t3.order_id = t1.order_id
    WHERE
        t2.cancellation IS NULL
    GROUP BY 
        t1.order_id,
        t1.pizza_id,
        t3.total_extras
)
SELECT 
    SUM(total_price) + SUM(total_extras) AS total_income
FROM 
    calculate_totals;
