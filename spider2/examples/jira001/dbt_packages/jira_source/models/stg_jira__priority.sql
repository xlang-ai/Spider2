{{ config(enabled=var('jira_using_priorities', True)) }}

with base as (

    select * 
    from {{ ref('stg_jira__priority_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__priority_tmp')),
                staging_columns=get_priority_columns()
            )
        }}
    from base
),

final as (
    
    select 
        description as priority_description,
        id as priority_id,
        name as priority_name,
        _fivetran_synced
    from fields
)

select * 
from final