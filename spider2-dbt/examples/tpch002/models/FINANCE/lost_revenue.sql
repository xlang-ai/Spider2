WITH

-- Only customers who have orders
ro as (
    select
        o.o_orderkey,
        c.c_custkey
    from {{ source('TPCH_SF1', 'orders') }} o
    inner join {{ source('TPCH_SF1', 'customer') }} c
        on o.o_custkey = c.c_custkey
),

rl as (
    SELECT c.c_custkey
    ,c.c_name
    ,sum(revenue) AS revenue_lost
    ,c_acctbal
    ,n.n_name 
    ,c_address 
    ,c_phone 
    ,c_comment
    FROM ro left join (SELECT l.l_orderkey AS ORDER_ID, o.o_custkey AS CUSTOMER_ID, SUM(l.l_extendedprice * (1 - l.l_discount)) AS REVENUE
        FROM {{ source('TPCH_SF1', 'lineitem') }} l LEFT JOIN {{ source('TPCH_SF1', 'orders') }}  o ON l.l_orderkey = o.o_orderkey
        WHERE l.l_returnflag = 'R' GROUP BY o.o_custkey, l.l_orderkey
    ) lo on lo.ORDER_ID = ro.o_orderkey and lo.CUSTOMER_ID = ro.c_custkey
    LEFT JOIN {{ source('TPCH_SF1', 'customer') }} c ON c.c_custkey = lo.CUSTOMER_ID LEFT JOIN {{ source('TPCH_SF1', 'nation') }} n ON c.c_nationkey = n.n_nationkey
    WHERE lo.CUSTOMER_ID is not null GROUP BY c.c_custkey,c.c_name,c.c_acctbal,c.c_phone,n.n_name,c.c_address,c.c_comment ORDER BY revenue_lost DESC
)

select * from rl