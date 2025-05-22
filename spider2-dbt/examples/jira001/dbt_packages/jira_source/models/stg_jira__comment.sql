
with base as (

    select * 
    from {{ ref('stg_jira__comment_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__comment_tmp')),
                staging_columns=get_comment_columns()
            )
        }}
    from base
),

final as (
    
    select 
        author_id as author_user_id,
        body,
        cast(created as {{ dbt.type_timestamp() }}) as created_at,
        id as comment_id,
        issue_id,
        is_public,
        update_author_id as last_update_user_id,
        cast(updated as {{ dbt.type_timestamp() }}) as last_updated_at,
        _fivetran_synced
    from fields
)

select * 
from final