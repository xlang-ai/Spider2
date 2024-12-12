{% macro get_discount_code_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "price_rule_id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "usage_count", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}
