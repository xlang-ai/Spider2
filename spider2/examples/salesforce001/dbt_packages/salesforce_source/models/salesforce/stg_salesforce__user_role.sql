--To disable this model, set the salesforce__user_role_enabled within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__user_role_enabled', True)) }}

{% set user_role_column_list = get_user_role_columns() -%}
{% set user_role_dict = column_list_to_dict(user_role_column_list) -%}

with fields as (

    select
        
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','user_role')),
                staging_columns=user_role_column_list
            )
        }}

    from {{ source('salesforce','user_role') }}
), 

final as (

    select
        _fivetran_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("developer_name", user_role_dict ) }},
        {{ salesforce_source.coalesce_rename("id", user_role_dict, alias="user_role_id") }},
        {{ salesforce_source.coalesce_rename("name", user_role_dict, alias="user_role_name") }},
        {{ salesforce_source.coalesce_rename("opportunity_access_for_account_owner", user_role_dict ) }},
        {{ salesforce_source.coalesce_rename("parent_role_id", user_role_dict ) }},
        {{ salesforce_source.coalesce_rename("rollup_description", user_role_dict ) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__user_role_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final