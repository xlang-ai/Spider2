
with base as (

    select * 
    from {{ ref('stg_sap__faglflexa_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__faglflexa_tmp')),
                staging_columns=get_faglflexa_columns()
            )
        }}
    from base
),

final as (   

    select
        cast(rclnt as {{ dbt.type_string() }}) as rclnt,
        ryear,
        docnr,
        cast(rldnr as {{ dbt.type_string() }}) as rldnr,
        cast(rbukrs as {{ dbt.type_string() }}) as rbukrs,
        docln,
        activ,
        rmvct,
        rtcur,
        runit,
        awtyp,
        rrcty,
        rvers,
        logsys,
        racct,
        cost_elem,
        rcntr,
        prctr,
        rfarea,
        rbusa,
        kokrs,
        segment,
        scntr,
        pprctr,
        sfarea,
        sbusa,
        rassc,
        psegment,
        tsl,
        hsl,
        ksl,
        osl,
        msl,
        wsl,
        drcrk,
        poper,
        rwcur,
        cast(gjahr as {{ dbt.type_string() }}) as gjahr,
        budat,
        cast(belnr as {{ dbt.type_string() }}) as belnr,
        cast(buzei as {{ dbt.type_string() }}) as buzei,
        bschl,
        bstat,
        faglflexa_timestamp,
        _fivetran_synced
    from fields
)

select * 
from final