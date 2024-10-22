--To disable this model, set the salesforce__order_enabled within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__order_enabled', True)) }}

{% set order_column_list = get_order_columns() -%}
{% set order_dict = column_list_to_dict(order_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','order')),
                staging_columns=order_column_list
            )
        }}
        
    from {{ source('salesforce','order') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("id", order_dict, alias="order_id") }},
        {{ salesforce_source.coalesce_rename("account_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("activated_by_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("activated_date", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_city", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_country", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_country_code", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_postal_code", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_state", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_state_code", order_dict) }},
        {{ salesforce_source.coalesce_rename("billing_street", order_dict) }},
        {{ salesforce_source.coalesce_rename("contract_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("created_by_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", order_dict) }},
        {{ salesforce_source.coalesce_rename("description", order_dict, alias="order_description") }},
        {{ salesforce_source.coalesce_rename("end_date", order_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", order_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_by_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_date", order_dict) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", order_dict) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", order_dict) }},
        {{ salesforce_source.coalesce_rename("opportunity_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("order_number", order_dict) }},
        {{ salesforce_source.coalesce_rename("original_order_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("owner_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("pricebook_2_id", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_city", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_country", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_country_code", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_postal_code", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_state", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_state_code", order_dict) }},
        {{ salesforce_source.coalesce_rename("shipping_street", order_dict) }},
        {{ salesforce_source.coalesce_rename("status", order_dict) }},
        {{ salesforce_source.coalesce_rename("total_amount", order_dict, datatype=dbt.type_numeric()) }},
        {{ salesforce_source.coalesce_rename("type", order_dict) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__order_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)