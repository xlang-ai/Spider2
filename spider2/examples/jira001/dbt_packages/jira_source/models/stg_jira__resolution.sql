
with base as (

    select * 
    from {{ ref('stg_jira__resolution_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__resolution_tmp')),
                staging_columns=get_resolution_columns()
            )
        }}
    from base
),

final as (
    
    select 
        description as resolution_description,
        id as resolution_id,
        name as resolution_name,
        _fivetran_synced
    from fields
)

select * 
from final
