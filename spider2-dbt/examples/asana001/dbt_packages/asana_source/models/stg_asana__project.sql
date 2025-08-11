
with base as (

    select * 
    from {{ ref('stg_asana__project_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__project_tmp')),
                staging_columns=get_project_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as project_id,
        archived as is_archived,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        current_status,
        cast(due_date as {{ dbt.type_timestamp() }}) as due_date,
        cast(modified_at as {{ dbt.type_timestamp() }}) as modified_at,
        name as project_name,
        owner_id as owner_user_id,
        public as is_public,
        team_id,
        workspace_id,
        notes
    from fields
)

select * 
from final
