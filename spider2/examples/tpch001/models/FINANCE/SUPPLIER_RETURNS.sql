WITH

top10s as (
    SELECT
        *
    FROM (
        SELECT 
            *, 
            ROW_NUMBER() OVER(PARTITION BY month ORDER BY month DESC, parts_returned DESC, total_revenue_lost DESC) as seq
        FROM (
            SELECT 
                date_trunc('month', order_date) as month
                ,supplier_id
                ,part_id
                ,COUNT(order_id || line_id) as parts_returned
                ,SUM(customer_cost) as total_revenue_lost
            FROM 
                {{ ref('order_line_items') }}
            WHERE 
                item_status = 'R'
            GROUP BY 
                month
                ,supplier_id
                ,part_id
        )
    )
    WHERE 
        seq <= 10
    ORDER BY
        month DESC
        , seq DESC
)

SELECT 
    top10s.*
    , s.S_NAME
    , s.S_PHONE
    , p.P_NAME
FROM 
    top10s
LEFT JOIN {{ source('TPCH_SF1', 'supplier') }} s
    ON top10s.SUPPLIER_ID = s.S_SUPPKEY
LEFT JOIN {{ source('TPCH_SF1', 'part') }} p
    ON top10s.PART_ID = p.P_PARTKEY