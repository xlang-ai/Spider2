WITH product_viewed AS (
    SELECT
        t1."page_id",
        SUM(CASE WHEN "event_type" = 1 THEN 1 ELSE 0 END) AS "n_page_views",
        SUM(CASE WHEN "event_type" = 2 THEN 1 ELSE 0 END) AS "n_added_to_cart"
    FROM
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" AS t1
    JOIN
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" AS t2
    ON
        t1."page_id" = t2."page_id"
    WHERE
        t1."product_id" IS NOT NULL
    GROUP BY
        t1."page_id"
),
product_purchased AS (
    SELECT
        t2."page_id",
        SUM(CASE WHEN "event_type" = 2 THEN 1 ELSE 0 END) AS "purchased_from_cart"
    FROM
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" AS t1
    JOIN
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" AS t2
    ON
        t1."page_id" = t2."page_id"
    WHERE
        t1."product_id" IS NOT NULL
        AND EXISTS (
            SELECT
                "visit_id"
            FROM
                "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS"
            WHERE
                "event_type" = 3
                AND t2."visit_id" = "visit_id"
        )
        AND t1."page_id" NOT IN (1, 2, 12, 13)
    GROUP BY
        t2."page_id"
),
product_abandoned AS (
    SELECT
        t2."page_id",
        SUM(CASE WHEN "event_type" = 2 THEN 1 ELSE 0 END) AS "abandoned_in_cart"
    FROM
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" AS t1
    JOIN
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" AS t2
    ON
        t1."page_id" = t2."page_id"
    WHERE
        t1."product_id" IS NOT NULL
        AND NOT EXISTS (
            SELECT
                "visit_id"
            FROM
                "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS"
            WHERE
                "event_type" = 3
                AND t2."visit_id" = "visit_id"
        )
        AND t1."page_id" NOT IN (1, 2, 12, 13)
    GROUP BY
        t2."page_id"
)
SELECT
    t1."page_id",
    t1."page_name",
    t2."n_page_views" AS "number of product being viewed",
    t2."n_added_to_cart" AS "number added to the cart",
    t4."abandoned_in_cart" AS "without being purchased in cart",
    t3."purchased_from_cart" AS "count of actual purchases"
FROM
    "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" AS t1
JOIN
    product_viewed AS t2 
ON
    t2."page_id" = t1."page_id"
JOIN
    product_purchased AS t3 
ON 
    t3."page_id" = t1."page_id"
JOIN
    product_abandoned AS t4 
ON 
    t4."page_id" = t1."page_id";
