--To disable this model, set the salesforce__product_2_enabled variable within your dbt_project.yml file to False.
{{ config(enabled=var('salesforce__product_2_enabled', True)) }}

{% set product_2_column_list = get_product_2_columns() -%}
{% set product_2_dict = column_list_to_dict(product_2_column_list) -%}

with fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','product_2')),
                staging_columns=product_2_column_list
            )
        }}
        
    from {{ source('salesforce','product_2') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("id", product_2_dict, alias="product_2_id") }},
        {{ salesforce_source.coalesce_rename("created_by_id", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("description", product_2_dict, alias="product_2_description") }},
        {{ salesforce_source.coalesce_rename("display_url", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("external_id", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("family", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("is_active", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("is_archived", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_by_id", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("last_modified_date", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("name", product_2_dict, alias="product_2_name") }},
        {{ salesforce_source.coalesce_rename("number_of_quantity_installments", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("number_of_revenue_installments", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("product_code", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("quantity_installment_period", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("quantity_schedule_type", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("quantity_unit_of_measure", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("record_type_id", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("revenue_installment_period", product_2_dict) }},
        {{ salesforce_source.coalesce_rename("revenue_schedule_type", product_2_dict) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__product_2_pass_through_columns') }}
        
    from fields
    where coalesce(_fivetran_active, true)
)

select *
from final
where not coalesce(is_deleted, false)