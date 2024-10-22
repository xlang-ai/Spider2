
with base as (

    select * 
    from {{ ref('stg_jira__status_category_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__status_category_tmp')),
                staging_columns=get_status_category_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as status_category_id,
        name as status_category_name
    from fields
)

select * 
from final