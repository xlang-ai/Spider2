--To disable this model, set the salesforce__opportunity_line_item_enabled variable within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__opportunity_line_item_enabled', True)) }}

{% set opportunity_line_item_column_list = get_opportunity_line_item_columns() -%}
{% set opportunity_line_item_dict = column_list_to_dict(opportunity_line_item_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','opportunity_line_item')),
                staging_columns=opportunity_line_item_column_list
            )
        }}
        
    from {{ source('salesforce','opportunity_line_item') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("id", opportunity_line_item_dict, alias="opportunity_line_item_id") }},
        {{ salesforce_source.coalesce_rename("created_by_id", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("description", opportunity_line_item_dict, alias="opportunity_line_item_description") }},
        {{ salesforce_source.coalesce_rename("discount", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("has_quantity_schedule", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("has_revenue_schedule", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("has_schedule", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_by_id", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_date", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("list_price", opportunity_line_item_dict, datatype=dbt.type_numeric()) }},
        {{ salesforce_source.coalesce_rename("name", opportunity_line_item_dict, alias="opportunity_line_item_name") }},
        {{ salesforce_source.coalesce_rename("opportunity_id", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("pricebook_entry_id", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("product_2_id", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("product_code", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("quantity", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("service_date", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("sort_order", opportunity_line_item_dict) }},
        {{ salesforce_source.coalesce_rename("total_price", opportunity_line_item_dict, datatype=dbt.type_numeric()) }},
        {{ salesforce_source.coalesce_rename("unit_price", opportunity_line_item_dict, datatype=dbt.type_numeric()) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__opportunity_line_item_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)