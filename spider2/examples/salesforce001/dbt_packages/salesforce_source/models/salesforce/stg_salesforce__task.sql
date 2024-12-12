--To disable this model, set the salesforce__task_enabled variable within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__task_enabled', True)) }}

{% set task_column_list = get_task_columns() -%}
{% set task_dict = column_list_to_dict(task_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','task')),
                staging_columns=task_column_list
            )
        }}
        
    from {{ source('salesforce','task') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("id", task_dict, alias="task_id") }},
        {{ salesforce_source.coalesce_rename("account_id", task_dict) }},
        {{ salesforce_source.coalesce_rename("activity_date", task_dict) }},
        {{ salesforce_source.coalesce_rename("call_disposition", task_dict) }},
        {{ salesforce_source.coalesce_rename("call_duration_in_seconds", task_dict) }},
        {{ salesforce_source.coalesce_rename("call_object", task_dict) }},
        {{ salesforce_source.coalesce_rename("call_type", task_dict) }},
        {{ salesforce_source.coalesce_rename("completed_date_time", task_dict) }},
        {{ salesforce_source.coalesce_rename("created_by_id", task_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", task_dict) }},
        {{ salesforce_source.coalesce_rename("description", task_dict, alias="task_description") }},
        {{ salesforce_source.coalesce_rename("is_archived", task_dict) }},
        {{ salesforce_source.coalesce_rename("is_closed", task_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", task_dict) }},
        {{ salesforce_source.coalesce_rename("is_high_priority", task_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_by_id", task_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_date", task_dict) }},
        {{ salesforce_source.coalesce_rename("owner_id", task_dict) }},
        {{ salesforce_source.coalesce_rename("priority", task_dict) }},
        {{ salesforce_source.coalesce_rename("record_type_id", task_dict) }},
        {{ salesforce_source.coalesce_rename("status", task_dict) }},
        {{ salesforce_source.coalesce_rename("subject", task_dict) }},
        {{ salesforce_source.coalesce_rename("task_subtype", task_dict) }},
        {{ salesforce_source.coalesce_rename("type", task_dict) }},
        {{ salesforce_source.coalesce_rename("what_count", task_dict) }},
        {{ salesforce_source.coalesce_rename("what_id", task_dict) }},
        {{ salesforce_source.coalesce_rename("who_count", task_dict) }},
        {{ salesforce_source.coalesce_rename("who_id", task_dict) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__task_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)