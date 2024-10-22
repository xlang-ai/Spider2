with base as (

    select * 
    from {{ ref('stg_sap__pa0007_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__pa0007_tmp')),
                staging_columns=get_pa0007_columns()
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
        arbst,
        awtyp,
        dysch,
        empct,
        flag1,
        flag2,
        flag3,
        flag4,
        grpvl,
        histo,
        itbld,
        itxex,
        jrstd,
        kztim,
        maxja,
        maxmo,
        maxta,
        maxwo,
        minja,
        minmo,
        minta,
        minwo,
        mostd,
        ordex,
        preas,
        refex,
        rese1,
        rese2,
        schkz,
        teilk,
        uname,
        wkwdy,
        wostd,
        wweek,
        zterf
    from fields
)

select *
from final