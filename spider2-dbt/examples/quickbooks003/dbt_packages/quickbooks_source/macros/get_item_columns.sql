{% macro get_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "asset_account_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "expense_account_id", "datatype": dbt.type_string()},
    {"name": "fully_qualified_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "income_account_id", "datatype": dbt.type_string()},
    {"name": "inventory_start_date", "datatype": "date"},
    {"name": "level", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "parent_item_id", "datatype": dbt.type_string()},
    {"name": "purchase_cost", "datatype": dbt.type_float()},
    {"name": "purchase_description", "datatype": dbt.type_string()},
    {"name": "purchase_tax_code_id", "datatype": dbt.type_string()},
    {"name": "purchase_tax_included", "datatype": "boolean"},
    {"name": "quantity_on_hand", "datatype": dbt.type_float()},
    {"name": "sales_tax_code_id", "datatype": dbt.type_string()},
    {"name": "sales_tax_included", "datatype": "boolean"},
    {"name": "stock_keeping_unit", "datatype": dbt.type_string()},
    {"name": "sub_item", "datatype": "boolean"},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "taxable", "datatype": "boolean"},
    {"name": "track_quantity_on_hand", "datatype": "boolean"},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "unit_price", "datatype": dbt.type_float()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
