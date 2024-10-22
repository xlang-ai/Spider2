
with base as (

    select * 
    from {{ ref('stg_asana__tag_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__tag_tmp')),
                staging_columns=get_tag_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as tag_id,
        name as tag_name,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at
    from fields
    where not _fivetran_deleted
)

select * 
from final
