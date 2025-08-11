select 
    e.p_name            AS Part_Name,
    e.p_retailprice     AS RetailPrice,
    e.s_name            AS Supplier_Name,
    e.p_mfgr            AS Part_Manufacturer,
    e.s_address         AS SuppAddr,
    e.s_phone           AS Supp_Phone,
    ps.PS_AVAILQTY      AS Num_Available 

from {{ ref('EUR_LOWCOST_BRASS_SUPPLIERS') }} e
LEFT JOIN {{ source('TPCH_SF1', 'supplier') }} s on e.S_NAME = s.S_NAME
LEFT JOIN
    {{ source('TPCH_SF1', 'partsupp') }} ps
on e.P_PARTKEY = ps.PS_PARTKEY
    and s.S_SUPPKEY = ps.PS_SUPPKEY

where n_name = 'UNITED KINGDOM'