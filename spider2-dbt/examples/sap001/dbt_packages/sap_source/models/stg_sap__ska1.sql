with base as (

    select * 
    from {{ ref('stg_sap__ska1_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__ska1_tmp')),
                staging_columns=get_ska1_columns()
            )
        }}
    from base
),

final as (
    
    select 
        mandt,
        ktopl,
        saknr,
        bilkt,
        gvtyp,
        vbund,
        xbilk,
        sakan,
        erdat,
        ernam,
        ktoks,
        xloev,
        xspea,
        xspeb,
        xspep,
        func_area,
        mustr,	
        _fivetran_rowid,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
