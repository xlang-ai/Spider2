WITH customer_date_range AS (
    SELECT 
        "customer_id",
        MIN(TO_DATE("txn_date")) AS start_date,
        MAX(TO_DATE("txn_date")) AS end_date
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY "customer_id"
),
all_days AS (
    SELECT 
        cdr."customer_id",
        DATEADD(day, seq.seq, cdr.start_date) AS date_day
    FROM customer_date_range cdr
    CROSS JOIN (
        SELECT ROW_NUMBER() OVER (ORDER BY NULL) - 1 AS seq
        FROM TABLE(GENERATOR(ROWCOUNT => 1000))
    ) seq
    WHERE DATEADD(day, seq.seq, cdr.start_date) <= cdr.end_date
),
daily_transactions AS (
    SELECT 
        "customer_id",
        TO_DATE("txn_date") AS txn_date,
        SUM(CASE 
            WHEN "txn_type" = 'deposit' THEN "txn_amount"
            WHEN "txn_type" = 'purchase' THEN -"txn_amount"
            WHEN "txn_type" = 'withdrawal' THEN -"txn_amount"
            ELSE 0 
        END) AS daily_net_change
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."CUSTOMER_TRANSACTIONS"
    GROUP BY "customer_id", TO_DATE("txn_date")
),
daily_balances AS (
    SELECT 
        ad."customer_id",
        ad.date_day,
        COALESCE(dt.daily_net_change, 0) AS daily_change,
        SUM(COALESCE(dt.daily_net_change, 0)) OVER (
            PARTITION BY ad."customer_id" 
            ORDER BY ad.date_day 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_balance
    FROM all_days ad
    LEFT JOIN daily_transactions dt 
        ON ad."customer_id" = dt."customer_id" 
        AND ad.date_day = dt.txn_date
),
non_negative_balances AS (
    SELECT 
        "customer_id",
        date_day,
        GREATEST(running_balance, 0) AS daily_balance,
        DATE_TRUNC('month', date_day) AS month_start
    FROM daily_balances
),
monthly_max_balances AS (
    SELECT 
        "customer_id",
        month_start,
        MAX(daily_balance) AS max_daily_balance
    FROM non_negative_balances
    GROUP BY "customer_id", month_start
)
SELECT 
    month_start,
    SUM(max_daily_balance) AS monthly_total_max_balance
FROM monthly_max_balances
GROUP BY month_start
ORDER BY month_start;