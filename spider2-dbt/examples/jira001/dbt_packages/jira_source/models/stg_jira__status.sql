with base as (

    select * 
    from {{ ref('stg_jira__status_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__status_tmp')),
                staging_columns=get_status_columns()
            )
        }}
    from base
),

final as (

    select
        description as status_description,
        id as status_id,
        name as status_name,
        status_category_id,
        _fivetran_synced
    from fields
)

select * 
from final