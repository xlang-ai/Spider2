with base as (

    select * 
    from {{ ref('stg_sap__t880_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_sap__t880_tmp')),
                staging_columns=get_t880_columns()
            )
        }}
    from base
),

final as (

    select
        cast(mandt as {{ dbt.type_string() }}) as mandt,
        rcomp,
        name1
    from fields
)

select * 
from final