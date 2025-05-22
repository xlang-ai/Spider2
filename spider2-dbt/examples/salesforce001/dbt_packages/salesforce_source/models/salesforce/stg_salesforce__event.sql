--To disable this model, set the salesforce__event_enabled variable within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__event_enabled', True)) }}

{% set event_column_list = get_event_columns() -%}
{% set event_dict = column_list_to_dict(event_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','event')),
                staging_columns=event_column_list
            )
        }}

    from {{ source('salesforce','event') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("id", event_dict, alias="event_id") }},
        {{ salesforce_source.coalesce_rename("account_id", event_dict) }},
        {{ salesforce_source.coalesce_rename("activity_date", event_dict) }},
        {{ salesforce_source.coalesce_rename("activity_date_time", event_dict) }},
        {{ salesforce_source.coalesce_rename("created_by_id", event_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", event_dict) }},
        {{ salesforce_source.coalesce_rename("description", event_dict, alias="event_description") }},
        {{ salesforce_source.coalesce_rename("end_date", event_dict) }},
        {{ salesforce_source.coalesce_rename("end_date_time", event_dict) }},
        {{ salesforce_source.coalesce_rename("event_subtype", event_dict) }},
        {{ salesforce_source.coalesce_rename("group_event_type", event_dict) }},
        {{ salesforce_source.coalesce_rename("is_archived", event_dict) }},
        {{ salesforce_source.coalesce_rename("is_child", event_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", event_dict) }},
        {{ salesforce_source.coalesce_rename("is_group_event", event_dict) }},
        {{ salesforce_source.coalesce_rename("is_recurrence", event_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_by_id", event_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_date", event_dict) }},
        {{ salesforce_source.coalesce_rename("location", event_dict) }},
        {{ salesforce_source.coalesce_rename("owner_id", event_dict) }},
        {{ salesforce_source.coalesce_rename("start_date_time", event_dict) }},
        {{ salesforce_source.coalesce_rename("subject", event_dict) }},
        {{ salesforce_source.coalesce_rename("type", event_dict) }},
        {{ salesforce_source.coalesce_rename("what_count", event_dict) }},
        {{ salesforce_source.coalesce_rename("what_id", event_dict) }},
        {{ salesforce_source.coalesce_rename("who_count", event_dict) }},
        {{ salesforce_source.coalesce_rename("who_id", event_dict) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__event_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)
