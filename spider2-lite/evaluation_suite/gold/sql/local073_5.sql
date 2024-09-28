WITH cte_cleaned_customer_orders AS (
    SELECT
        *,
        ROW_NUMBER() OVER () AS original_row_number
    FROM 
        pizza_clean_customer_orders
),
split_regular_toppings AS (
    SELECT
        pizza_id,
        TRIM(SUBSTR(toppings, 1, INSTR(toppings || ',', ',') - 1)) AS topping_id,
        SUBSTR(toppings || ',', INSTR(toppings || ',', ',') + 1) AS remaining_toppings
    FROM 
        pizza_recipes
    UNION ALL
    SELECT
        pizza_id,
        TRIM(SUBSTR(remaining_toppings, 1, INSTR(remaining_toppings, ',') - 1)) AS topping_id,
        SUBSTR(remaining_toppings, INSTR(remaining_toppings, ',') + 1) AS remaining_toppings
    FROM 
        split_regular_toppings
    WHERE
        remaining_toppings <> ''
),
cte_base_toppings AS (
    SELECT
        t1.order_id,
        t1.customer_id,
        t1.pizza_id,
        t1.order_time,
        t1.original_row_number,
        t2.topping_id
    FROM 
        cte_cleaned_customer_orders AS t1
    LEFT JOIN 
        split_regular_toppings AS t2
    ON 
        t1.pizza_id = t2.pizza_id
),
split_exclusions AS (
    SELECT
        order_id,
        customer_id,
        pizza_id,
        order_time,
        original_row_number,
        TRIM(SUBSTR(exclusions, 1, INSTR(exclusions || ',', ',') - 1)) AS topping_id,
        SUBSTR(exclusions || ',', INSTR(exclusions || ',', ',') + 1) AS remaining_exclusions
    FROM 
        cte_cleaned_customer_orders
    WHERE 
        exclusions IS NOT NULL
    UNION ALL
    SELECT
        order_id,
        customer_id,
        pizza_id,
        order_time,
        original_row_number,
        TRIM(SUBSTR(remaining_exclusions, 1, INSTR(remaining_exclusions, ',') - 1)) AS topping_id,
        SUBSTR(remaining_exclusions, INSTR(remaining_exclusions, ',') + 1) AS remaining_exclusions
    FROM 
        split_exclusions
    WHERE
        remaining_exclusions <> ''
),
split_extras AS (
    SELECT
        order_id,
        customer_id,
        pizza_id,
        order_time,
        original_row_number,
        TRIM(SUBSTR(extras, 1, INSTR(extras || ',', ',') - 1)) AS topping_id,
        SUBSTR(extras || ',', INSTR(extras || ',', ',') + 1) AS remaining_extras
    FROM 
        cte_cleaned_customer_orders
    WHERE 
        extras IS NOT NULL
    UNION ALL
    SELECT
        order_id,
        customer_id,
        pizza_id,
        order_time,
        original_row_number,
        TRIM(SUBSTR(remaining_extras, 1, INSTR(remaining_extras, ',') - 1)) AS topping_id,
        SUBSTR(remaining_extras, INSTR(remaining_extras, ',') + 1) AS remaining_extras
    FROM 
        split_extras
    WHERE
        remaining_extras <> ''
),
cte_combined_orders AS (
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        order_time,
        original_row_number,
        topping_id
    FROM 
        cte_base_toppings
    WHERE topping_id NOT IN (SELECT topping_id FROM split_exclusions WHERE split_exclusions.order_id = cte_base_toppings.order_id)
    UNION ALL
    SELECT 
        order_id,
        customer_id,
        pizza_id,
        order_time,
        original_row_number,
        topping_id
    FROM 
        split_extras
)
SELECT
    t2.topping_name,
    COUNT(*) AS topping_count
FROM 
    cte_combined_orders AS t1
JOIN 
    pizza_toppings AS t2
ON 
    t1.topping_id = t2.topping_id
GROUP BY 
    t2.topping_name
ORDER BY 
    topping_count DESC;
