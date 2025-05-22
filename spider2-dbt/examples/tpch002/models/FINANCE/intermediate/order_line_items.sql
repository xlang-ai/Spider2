WITH 

buyer_costs as (
        SELECT
                l_orderkey as order_id,
                l_linenumber as line_id,
                l_suppkey as supplier_id,
                l_partkey as part_id,
                l_returnflag as item_status,
                ROUND(l_extendedprice * (1 - l_discount), 2) as item_cost
        FROM {{ source('TPCH_SF1', 'lineitem') }}    
)

SELECT 
        o.o_custkey as customer_id,
        o.o_orderdate as order_date,
        -- Order id + line id create the primary key
        o.o_orderkey as order_id,
        bc.line_id,
        bc.supplier_id,
        bc.part_id,
        bc.item_status,
        bc.item_cost as customer_cost
FROM 
        buyer_costs bc 
LEFT JOIN 
        {{ source('TPCH_SF1', 'orders') }} o ON bc.order_id = o.o_orderkey
ORDER BY
        o.o_custkey,
        o.o_orderdate,
        o.o_orderkey,
        bc.line_id