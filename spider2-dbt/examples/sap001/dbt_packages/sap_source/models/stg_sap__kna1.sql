with base as (

    select * 
    from {{ ref('stg_sap__kna1_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__kna1_tmp')),
                staging_columns=get_kna1_columns()
            )
        }}
    from base
),

final as (

    select
        mandt,
        kunnr,
        brsch,
        ktokd,
        kukla,
        land1,
        lifnr,
        loevm,
        name1,
        name2,
        name3,
        niels,
        ort01,
        ort02,
        periv,
        pfach,
        pfort,
        pstl2,
        pstlz,
        regio,
        counc,
        sortl,
        spras,
        stcd1,
        stcd2,
        stcd3,
        stras,
        telf1,
        telfx,
        xcpdk,
        vbund,
        dear6,
        bran1,
        bran2,
        bran3,
        bran4,
        bran5,
        abrvw,
        werks
    from fields
)

select *
from final