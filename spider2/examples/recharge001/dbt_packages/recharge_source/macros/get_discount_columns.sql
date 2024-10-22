
{% macro get_discount_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "starts_at", "datatype": dbt.type_timestamp()},
    {"name": "ends_at", "datatype": dbt.type_timestamp()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "value", "datatype": dbt.type_float()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "usage_limits", "datatype": dbt.type_int()},
    {"name": "applies_to", "datatype": dbt.type_string()},
    {"name": "applies_to_resource", "datatype": dbt.type_string()},
    {"name": "applies_to_id", "datatype": dbt.type_int()},
    {"name": "applies_to_product_type", "datatype": dbt.type_string()},
    {"name": "minimum_order_amount", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}