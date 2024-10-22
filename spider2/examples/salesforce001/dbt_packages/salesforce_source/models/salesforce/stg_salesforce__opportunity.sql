{% set opportunity_column_list = get_opportunity_columns() -%}
{% set opportunity_dict = column_list_to_dict(opportunity_column_list) -%}

with fields as (

    select

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('salesforce','opportunity')),
                staging_columns=opportunity_column_list
            )
        }}

    from {{ source('salesforce','opportunity') }}
), 

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        {{ salesforce_source.coalesce_rename("account_id", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("amount", opportunity_dict, datatype=dbt.type_numeric()) }},
        {{ salesforce_source.coalesce_rename("campaign_id", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("close_date", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("created_date", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("description", opportunity_dict, alias="opportunity_description") }},
        {{ salesforce_source.coalesce_rename("expected_revenue", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("fiscal", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("fiscal_quarter", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("fiscal_year", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("forecast_category", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("forecast_category_name", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("has_open_activity", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("has_opportunity_line_item", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("has_overdue_task", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("id", opportunity_dict, alias="opportunity_id") }},
        {{ salesforce_source.coalesce_rename("is_closed", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("is_deleted", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("is_won", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("last_activity_date", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("last_referenced_date", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("last_viewed_date", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("lead_source", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("name", opportunity_dict, alias="opportunity_name") }},
        {{ salesforce_source.coalesce_rename("next_step", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("owner_id", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("probability", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("record_type_id", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("stage_name", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("synced_quote_id", opportunity_dict) }},
        {{ salesforce_source.coalesce_rename("type", opportunity_dict) }}
        
        {{ fivetran_utils.fill_pass_through_columns('salesforce__opportunity_pass_through_columns') }}

    from fields
    where coalesce(_fivetran_active, true)
), 

calculated as (
        
    select 
        *,
        created_date >= {{ dbt.date_trunc('month', dbt.current_timestamp_backcompat()) }} as is_created_this_month,
        created_date >= {{ dbt.date_trunc('quarter', dbt.current_timestamp_backcompat()) }} as is_created_this_quarter,
        {{ dbt.datediff(dbt.current_timestamp_backcompat(), 'created_date', 'day') }} as days_since_created,
        {{ dbt.datediff('close_date', 'created_date', 'day') }} as days_to_close,
        {{ dbt.date_trunc('month', 'close_date') }} = {{ dbt.date_trunc('month', dbt.current_timestamp_backcompat()) }} as is_closed_this_month,
        {{ dbt.date_trunc('quarter', 'close_date') }} = {{ dbt.date_trunc('quarter', dbt.current_timestamp_backcompat()) }} as is_closed_this_quarter
    from final
)

select * 
from calculated
where not coalesce(is_deleted, false)