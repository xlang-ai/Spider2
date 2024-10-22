{{ config(enabled=var('jira_using_components', True)) }}

with base as (

    select * 
    from {{ ref('stg_jira__component_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__component_tmp')),
                staging_columns=get_component_columns()
            )
        }}
    from base
),

final as (
    
    select 
        description as component_description,
        id as component_id,
        name as component_name,
        project_id,
        _fivetran_synced
    from fields
)

select * 
from final