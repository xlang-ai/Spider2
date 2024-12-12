{% macro get_inventory_item_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "cost", "datatype": dbt.type_float()},
    {"name": "country_code_of_origin", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "province_code_of_origin", "datatype": dbt.type_string()},
    {"name": "requires_shipping", "datatype": "boolean"},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "tracked", "datatype": "boolean"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
