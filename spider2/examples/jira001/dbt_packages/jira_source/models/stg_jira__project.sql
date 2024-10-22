with base as (
    
    select *
    from {{ ref('stg_jira__project_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__project_tmp')),
                staging_columns=get_project_columns()
            )
        }}
    from base

),

final as (

    select 
        description as project_description,
        id as project_id,
        key as project_key,
        lead_id as project_lead_user_id,
        name as project_name,
        project_category_id,
        permission_scheme_id,
        _fivetran_synced
    from fields
)

select * 
from final