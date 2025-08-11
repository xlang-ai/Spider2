with base as (

    select * 
    from {{ ref('stg_sap__pa0001_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__pa0001_tmp')),
                staging_columns=get_pa0001_columns()
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
        abkrs,
        aedtm,
        ansvh,
        btrtl,
        budget_pd,
        bukrs,
        ename,
        fistl,
        fkber,
        flag1,
        flag2,
        flag3,
        flag4,
        geber,
        grant_nbr,
        grpvl,
        gsber,
        histo,
        itbld,
        itxex,
        juper,
        kokrs,
        kostl,
        mstbr,
        ordex,
        orgeh,
        otype,
        persg,
        persk,
        plans,
        preas,
        refex,
        rese1,
        rese2,
        sacha,
        sachp,
        sachz,
        sbmod,
        sgmnt,
        sname,
        stell,
        uname,
        vdsk1,
        werks
    from fields
)

select *
from final