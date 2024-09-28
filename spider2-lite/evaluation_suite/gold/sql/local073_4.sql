WITH id_customer_orders AS (
    SELECT
        ROW_NUMBER() OVER() AS row_id,
        order_id,
        customer_id,
        pizza_id,
        exclusions,
        extras,
        order_time
    FROM
        pizza_clean_customer_orders co
),
get_pizza_toppings AS (
    WITH RECURSIVE split_toppings AS (
        SELECT
            row_id,
            order_id,
            TRIM(SUBSTR(toppings, 1, INSTR(toppings || ',', ',') - 1)) AS single_toppings,
            SUBSTR(toppings || ',', INSTR(toppings || ',', ',') + 1) AS remaining_toppings
        FROM
            id_customer_orders c
        JOIN
            pizza_recipes pr
        ON
            c.pizza_id = pr.pizza_id
        UNION ALL
        SELECT
            row_id,
            order_id,
            TRIM(SUBSTR(remaining_toppings, 1, INSTR(remaining_toppings, ',') - 1)) AS single_toppings,
            SUBSTR(remaining_toppings, INSTR(remaining_toppings, ',') + 1) AS remaining_toppings
        FROM
            split_toppings
        WHERE
            remaining_toppings <> ''
    )
    SELECT
        row_id,
        order_id,
        single_toppings,
        COUNT(*) OVER (PARTITION BY row_id, order_id) AS topping_count
    FROM
        split_toppings
),
ingredients AS (
    WITH temp AS (
        SELECT
            t2.row_id,
            t2.order_id,
            t2.customer_id,
            t2.order_time,
            t1.pizza_name,
            (
                SELECT
                    GROUP_CONCAT(topping_name, ', ')
                FROM
                    pizza_toppings
                WHERE
                    topping_id IN (
                        SELECT single_toppings FROM get_pizza_toppings WHERE row_id = t2.row_id
                    )
                    AND topping_id NOT IN (
                        SELECT exclusions FROM pizza_get_exclusions WHERE order_id = t2.order_id
                    )
            ) AS all_toppings,
            (
                SELECT
                    GROUP_CONCAT(topping_name, ', ')
                FROM
                    pizza_toppings
                WHERE
                    topping_id IN (
                        SELECT extras FROM pizza_get_extras WHERE order_id = t2.order_id
                    )
            ) AS all_extras
        FROM
            pizza_names t1
        JOIN
            id_customer_orders t2
        ON
            t2.pizza_id = t1.pizza_id
        ORDER BY
            t2.row_id
    )
    SELECT *, 
        COALESCE(all_toppings, '') || ',' || COALESCE(all_extras, '') AS all_ingredients
    FROM temp
),
split_ingredients AS (
    SELECT
        row_id,
        order_id,
        customer_id,
        pizza_name,
        order_time,
        all_extras,
        TRIM(SUBSTR(all_ingredients, 1, INSTR(all_toppings || ',', ',') - 1)) AS each_ingredient,
        SUBSTR(all_ingredients || ',', INSTR(all_toppings || ',', ',') + 1) AS remaining_ingredients
    FROM
        ingredients
    UNION ALL
    SELECT
        row_id,
        order_id,
        customer_id,
        pizza_name,
        order_time,
        all_extras,
        TRIM(SUBSTR(remaining_ingredients, 1, INSTR(remaining_ingredients, ',') - 1)) AS each_ingredient,
        SUBSTR(remaining_ingredients, INSTR(remaining_ingredients, ',') + 1)
    FROM
        split_ingredients
    WHERE
        remaining_ingredients <> ''
),
create_strings AS (
    SELECT
        row_id,
        order_id,
        customer_id,
        pizza_name,
        order_time,
        CASE
            WHEN COUNT(each_ingredient) > 1 THEN '2x' || each_ingredient
            WHEN each_ingredient != '' THEN each_ingredient
        END AS new_ingredient
    FROM
        split_ingredients
    GROUP BY 
        row_id,
        order_id,
        customer_id,
        pizza_name,
        order_time,
        each_ingredient
    ORDER BY
        new_ingredient
)
SELECT
    order_id,
    customer_id,
    CASE
        WHEN pizza_name = 'Meatlovers' THEN 1
        ELSE 2
    END AS pizza_id,
    order_time,
    row_id AS original_row_number,
    pizza_name || ': ' || GROUP_CONCAT(new_ingredient, ', ') AS toppings
FROM
    create_strings
GROUP BY
    row_id,
    order_id,
    customer_id,
    pizza_name,
    order_time
ORDER BY
    row_id;
