--To disable this model, set the salesforce__lead_enabled within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__lead_enabled', True)) }}

{% set lead_column_list = get_lead_columns() -%}
{% set lead_dict = column_list_to_dict(lead_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','lead')),
                staging_columns=lead_column_list
            )
        }}
        
    from {{ source('salesforce','lead') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("id", lead_dict, alias="lead_id") }},
        {{ salesforce_source.coalesce_rename("annual_revenue", lead_dict, datatype=dbt.type_numeric()) }},
        {{ salesforce_source.coalesce_rename("city", lead_dict) }},
        {{ salesforce_source.coalesce_rename("company", lead_dict) }},
        {{ salesforce_source.coalesce_rename("converted_account_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("converted_contact_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("converted_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("converted_opportunity_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("country", lead_dict) }},
        {{ salesforce_source.coalesce_rename("country_code", lead_dict) }},
        {{ salesforce_source.coalesce_rename("created_by_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("description", lead_dict, alias="lead_description") }},
        {{ salesforce_source.coalesce_rename("email", lead_dict) }},
        {{ salesforce_source.coalesce_rename("email_bounced_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("email_bounced_reason", lead_dict) }},
        {{ salesforce_source.coalesce_rename("first_name", lead_dict) }},
        {{ salesforce_source.coalesce_rename("has_opted_out_of_email", lead_dict) }},
        {{ salesforce_source.coalesce_rename("individual_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("industry", lead_dict) }},
        {{ salesforce_source.coalesce_rename("is_converted", lead_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", lead_dict) }},
        {{ salesforce_source.coalesce_rename("is_unread_by_owner", lead_dict) }},
        {{ salesforce_source.coalesce_rename("last_activity_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_by_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("last_name", lead_dict) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", lead_dict) }},
        {{ salesforce_source.coalesce_rename("lead_source", lead_dict) }},
        {{ salesforce_source.coalesce_rename("master_record_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("mobile_phone", lead_dict) }},
        {{ salesforce_source.coalesce_rename("name", lead_dict, alias="lead_name") }},
        {{ salesforce_source.coalesce_rename("number_of_employees", lead_dict) }},
        {{ salesforce_source.coalesce_rename("owner_id", lead_dict) }},
        {{ salesforce_source.coalesce_rename("phone", lead_dict) }},
        {{ salesforce_source.coalesce_rename("postal_code", lead_dict) }},
        {{ salesforce_source.coalesce_rename("state", lead_dict) }},
        {{ salesforce_source.coalesce_rename("state_code", lead_dict) }},
        {{ salesforce_source.coalesce_rename("status", lead_dict) }},
        {{ salesforce_source.coalesce_rename("street", lead_dict) }},
        {{ salesforce_source.coalesce_rename("title", lead_dict) }},
        {{ salesforce_source.coalesce_rename("website", lead_dict) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__lead_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)