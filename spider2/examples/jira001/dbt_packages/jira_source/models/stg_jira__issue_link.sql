
with base as (

    select * 
    from {{ ref('stg_jira__issue_link_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__issue_link_tmp')),
                staging_columns=get_issue_link_columns()
            )
        }}
    from base
),

final as (
    
    select 
        issue_id,
        related_issue_id,
        relationship,
        _fivetran_synced 
    from fields
)

select * 
from final
