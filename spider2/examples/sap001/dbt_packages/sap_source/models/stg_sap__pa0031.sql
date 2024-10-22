with base as (

    select * 
    from {{ ref('stg_sap__pa0031_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__pa0031_tmp')),
                staging_columns=get_pa0031_columns()
            )
        }}
    from base
),

final as (
    
    select
        mandt,
        pernr,
        subty,
        objps,
        sprps,
        endda,
        begda,
        seqnr,
        aedtm,
        flag1,
        flag2,
        flag3,
        flag4,
        grpvl,
        histo,
        itbld,
        itxex,
        ordex,
        preas,
        refex,
        rese1,
        rese2,
        rfp01,
        rfp02,
        rfp03,
        rfp04,
        rfp05,
        rfp06,
        rfp07,
        rfp08,
        rfp09,
        rfp10,
        rfp11,
        rfp12,
        rfp13,
        rfp14,
        rfp15,
        rfp16,
        rfp17,
        rfp18,
        rfp19,
        rfp20,
        uname
    from fields
)

select *
from final