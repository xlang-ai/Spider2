{% set user_column_list = get_user_columns() -%}
{% set user_dict = column_list_to_dict(user_column_list) -%}

with fields as (

    select

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','user')),
                staging_columns=user_column_list
            )
        }}

    from {{ source('salesforce','user') }}
), 

final as (
    
    select 
        _fivetran_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("account_id", user_dict ) }},
        {{ salesforce_source.coalesce_rename("alias", user_dict ) }},
        {{ salesforce_source.coalesce_rename("city", user_dict ) }},
        {{ salesforce_source.coalesce_rename("company_name", user_dict ) }},
        {{ salesforce_source.coalesce_rename("contact_id", user_dict ) }},
        {{ salesforce_source.coalesce_rename("country", user_dict ) }},
        {{ salesforce_source.coalesce_rename("country_code", user_dict ) }},
        {{ salesforce_source.coalesce_rename("department", user_dict ) }},
        {{ salesforce_source.coalesce_rename("email", user_dict ) }},
        {{ salesforce_source.coalesce_rename("first_name", user_dict ) }},
        {{ salesforce_source.coalesce_rename("id", user_dict, alias="user_id" ) }},
        {{ salesforce_source.coalesce_rename("individual_id", user_dict ) }},
        {{ salesforce_source.coalesce_rename("is_active", user_dict ) }},
        {{ salesforce_source.coalesce_rename("last_login_date", user_dict ) }},
        {{ salesforce_source.coalesce_rename("last_name", user_dict ) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", user_dict ) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", user_dict ) }},
        {{ salesforce_source.coalesce_rename("manager_id", user_dict ) }},
        {{ salesforce_source.coalesce_rename("name", user_dict, alias="user_name" ) }},
        {{ salesforce_source.coalesce_rename("postal_code", user_dict ) }},
        {{ salesforce_source.coalesce_rename("profile_id", user_dict ) }},
        {{ salesforce_source.coalesce_rename("state", user_dict ) }},
        {{ salesforce_source.coalesce_rename("state_code", user_dict ) }},
        {{ salesforce_source.coalesce_rename("street", user_dict ) }},
        {{ salesforce_source.coalesce_rename("title", user_dict ) }},
        {{ salesforce_source.coalesce_rename("user_role_id", user_dict ) }},
        {{ salesforce_source.coalesce_rename("user_type", user_dict ) }},
        {{ salesforce_source.coalesce_rename("username", user_dict ) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__user_pass_through_columns') }}
    
    from fields
    where coalesce(_fivetran_active, true)
)

select * 
from final