with base as (

    select * 
    from {{ ref('stg_sap__t001_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__t001_tmp')),
                staging_columns=get_t001_columns()
            )
        }}
    from base
),

final as (

    select
        cast(mandt as {{ dbt.type_string() }}) as mandt,
        cast(bukrs as {{ dbt.type_string() }}) as bukrs,
        waers,
        periv,
        ktopl, 
        land1, 
        kkber,
        rcomp,
        butxt,
        spras
    from fields
)

select * 
from final