with base as (

    select * 
    from {{ ref('stg_jira__user_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__user_tmp')),
                staging_columns=get_user_columns()
            )
        }}
    from base
),

final as (

    select 
        email,
        id as user_id,
        locale,
        name as user_display_name,
        time_zone,
        username,
        _fivetran_synced
    from fields
)

select * 
from final