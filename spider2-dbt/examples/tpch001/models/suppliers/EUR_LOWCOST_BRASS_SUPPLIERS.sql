SELECT p_name, p_size, p_retailprice, s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment
FROM {{ source('TPCH_SF1', 'part') }}, 
{{ source('TPCH_SF1', 'supplier') }}, 
{{ source('TPCH_SF1', 'partsupp') }}, 
{{ source('TPCH_SF1', 'nation') }}, 
{{ source('TPCH_SF1', 'region') }}
WHERE
     p_partkey = ps_partkey AND s_suppkey = ps_suppkey
     AND p_size = 15 AND p_type LIKE '%BRASS'
     AND s_nationkey = n_nationkey AND n_regionkey = r_regionkey
     AND r_name = 'EUROPE' 
     AND ps_supplycost = (SELECT min(min_supply_cost.min_supply_cost) FROM {{ ref('min_supply_cost') }} WHERE PARTKEY=p_partkey)
ORDER BY s_acctbal DESC, n_name, s_name, p_partkey
