
with base as (

    select * 
    from {{ ref('stg_jira__field_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__field_tmp')),
                staging_columns=get_field_columns()
            )
        }}
    from base
),

final as (
    
    select 
        cast(id as {{ dbt.type_string() }}) as field_id,
        is_array,
        is_custom,
        name as field_name,
        _fivetran_synced
    from fields
)

select * 
from final