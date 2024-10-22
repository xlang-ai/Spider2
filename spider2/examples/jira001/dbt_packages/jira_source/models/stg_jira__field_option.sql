
with base as (

    select * 
    from {{ ref('stg_jira__field_option_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__field_option_tmp')),
                staging_columns=get_field_option_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as field_id,
        parent_id as parent_field_id,
        name as field_option_name
    from fields
)

select * 
from final