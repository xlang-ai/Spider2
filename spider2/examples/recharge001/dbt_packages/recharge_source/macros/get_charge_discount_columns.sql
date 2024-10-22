
{% macro get_charge_discount_columns() %}

{% set columns = [
    {"name": "charge_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "value", "datatype": dbt.type_float()},
    {"name": "value_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}