{% macro get_bundle_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "fully_qualified_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "print_grouped_items", "datatype": "boolean"},
    {"name": "purchase_cost", "datatype": dbt.type_float()},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "taxable", "datatype": "boolean"},
    {"name": "unit_price", "datatype": dbt.type_float()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
