with base as (
    
    select * 
    from {{ ref('stg_jira__issue_tmp') }}
    where not coalesce(_fivetran_deleted, false)
),

fields as (

    select 
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_jira__issue_tmp')),
                staging_columns=get_issue_columns()
            )
        }}
    from base
),

final as (

    select
        coalesce(original_estimate, _original_estimate) as original_estimate_seconds,
        coalesce(remaining_estimate, _remaining_estimate) as remaining_estimate_seconds,
        coalesce(time_spent, _time_spent) as time_spent_seconds,
        assignee as assignee_user_id,
        cast(created as {{ dbt.type_timestamp() }}) as created_at,
        cast(resolved  as {{ dbt.type_timestamp() }}) as resolved_at,
        creator as creator_user_id,
        description as issue_description,
        due_date,
        environment,
        id as issue_id,
        issue_type as issue_type_id,
        key as issue_key,
        parent_id as parent_issue_id,
        priority as priority_id,
        project as project_id,
        reporter as reporter_user_id,
        resolution as resolution_id,
        status as status_id,
        cast(status_category_changed as {{ dbt.type_timestamp() }}) as status_changed_at,
        summary as issue_name,
        cast(updated as {{ dbt.type_timestamp() }}) as updated_at,
        work_ratio,
        _fivetran_synced
    from fields
)

select * 
from final