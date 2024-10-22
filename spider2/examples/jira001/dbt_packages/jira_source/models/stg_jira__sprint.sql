{{ config(enabled=var('jira_using_sprints', True)) }}

with base as (

    select * 
    from {{ ref('stg_jira__sprint_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__sprint_tmp')),
                staging_columns=get_sprint_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as sprint_id,
        name as sprint_name,
        board_id,
        cast(complete_date as {{ dbt.type_timestamp() }}) as completed_at,
        cast(end_date as {{ dbt.type_timestamp() }}) as ended_at,
        cast(start_date as {{ dbt.type_timestamp() }}) as started_at,
        _fivetran_synced
    from fields
)

select * 
from final