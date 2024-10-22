{% set account_column_list = get_account_columns() -%}
{% set account_dict = column_list_to_dict(account_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','account')),
                staging_columns=account_column_list
            )
        }}

    from {{ source('salesforce','account') }}
), 

final as (
    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("account_number", account_dict) }},
        {{ salesforce_source.coalesce_rename("account_source", account_dict) }},
        {{ salesforce_source.coalesce_rename("annual_revenue", account_dict, datatype=dbt.type_numeric()) }},
        {{ salesforce_source.coalesce_rename("billing_city", account_dict) }},
        {{ salesforce_source.coalesce_rename("billing_country", account_dict) }},
        {{ salesforce_source.coalesce_rename("billing_postal_code", account_dict) }},
        {{ salesforce_source.coalesce_rename("billing_state", account_dict) }},
        {{ salesforce_source.coalesce_rename("billing_state_code", account_dict) }},
        {{ salesforce_source.coalesce_rename("billing_street", account_dict) }},
        {{ salesforce_source.coalesce_rename("description", account_dict, alias="account_description" ) }},
        {{ salesforce_source.coalesce_rename("id", account_dict, alias="account_id") }},
        {{ salesforce_source.coalesce_rename("industry", account_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", account_dict) }},
        {{ salesforce_source.coalesce_rename("last_activity_date", account_dict) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", account_dict) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", account_dict) }},
        {{ salesforce_source.coalesce_rename("master_record_id", account_dict) }},
        {{ salesforce_source.coalesce_rename("name", account_dict, alias="account_name" ) }},
        {{ salesforce_source.coalesce_rename("number_of_employees", account_dict) }},
        {{ salesforce_source.coalesce_rename("owner_id", account_dict) }},
        {{ salesforce_source.coalesce_rename("ownership", account_dict) }},
        {{ salesforce_source.coalesce_rename("parent_id", account_dict) }},
        {{ salesforce_source.coalesce_rename("rating", account_dict) }},
        {{ salesforce_source.coalesce_rename("record_type_id", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_city", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_country", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_country_code", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_postal_code", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_state", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_state_code", account_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_street", account_dict) }},
        {{ salesforce_source.coalesce_rename("type", account_dict) }},
        {{ salesforce_source.coalesce_rename("website", account_dict) }}

        {{ fivetran_utils.fill_pass_through_columns('salesforce__account_pass_through_columns') }}

    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)