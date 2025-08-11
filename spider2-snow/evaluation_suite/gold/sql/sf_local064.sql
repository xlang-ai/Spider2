WITH RECURSIVE generate_series AS (
    SELECT 0 AS "value"
    UNION ALL
    SELECT "value" + 1
    FROM generate_series
    WHERE "value" < 3
),
generate_months_cte AS (
    SELECT DISTINCT
        "customer_id",
        TO_CHAR(DATEADD(MONTH, "value", '2020-01-01'), 'YYYY-MM') AS "generated_month"
    FROM
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS", generate_series
    WHERE
        TO_CHAR(DATEADD(MONTH, "value", '2020-01-01'), 'YYYY') = '2020'
),
closing_balance AS (
    SELECT
        "customer_id",
        TO_CHAR(DATE_TRUNC('MONTH', TO_DATE("txn_date", 'YYYY-MM-DD')), 'YYYY-MM') AS "txn_month",  -- Convert to DATE
        SUM(
            CASE
                WHEN "txn_type" = 'deposit' THEN "txn_amount"
                ELSE - "txn_amount"
            END
        ) AS "transaction_amount"
    FROM
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    WHERE
        TO_CHAR(TO_DATE("txn_date", 'YYYY-MM-DD'), 'YYYY') = '2020'  -- Convert to DATE for comparison
    GROUP BY
        "customer_id",
        "txn_month"
),
final_balance AS (
    SELECT 
        t1."customer_id",
        t1."generated_month",
        COALESCE(SUM(t2."transaction_amount"), 0) AS "month_end_balance"
    FROM
        generate_months_cte AS t1
    LEFT JOIN 
        closing_balance AS t2
    ON
        t1."generated_month" = t2."txn_month"
        AND t1."customer_id" = t2."customer_id"
    GROUP BY
        t1."customer_id",
        t1."generated_month"
),
positive_balance_counts AS (
    SELECT
        "generated_month",
        COUNT(DISTINCT "customer_id") AS "positive_balance_count"
    FROM
        final_balance
    WHERE
        "month_end_balance" > 0
    GROUP BY
        "generated_month"
),
most_positive_month AS (
    SELECT
        "generated_month"
    FROM
        positive_balance_counts
    ORDER BY
        "positive_balance_count" DESC
    LIMIT 1
),
least_positive_month AS (
    SELECT
        "generated_month"
    FROM
        positive_balance_counts
    ORDER BY
        "positive_balance_count" ASC
    LIMIT 1
),
average_balance AS (
    SELECT
        'most_positive' AS "month_type",
        AVG("month_end_balance") AS "avg_balance"
    FROM
        final_balance
    WHERE
        "generated_month" = (SELECT "generated_month" FROM most_positive_month)
    UNION ALL
    SELECT
        'least_positive' AS "month_type",
        AVG("month_end_balance") AS "avg_balance"
    FROM
        final_balance
    WHERE
        "generated_month" = (SELECT "generated_month" FROM least_positive_month)
)
SELECT
    (SELECT "avg_balance" FROM average_balance WHERE "month_type" = 'most_positive') -
    (SELECT "avg_balance" FROM average_balance WHERE "month_type" = 'least_positive') AS "balance_diff";
