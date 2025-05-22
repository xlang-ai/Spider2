
with base as (

    select * 
    from {{ ref('stg_asana__section_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__section_tmp')),
                staging_columns=get_section_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as section_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        name as section_name,
        project_id
    from fields
)

select * 
from final
