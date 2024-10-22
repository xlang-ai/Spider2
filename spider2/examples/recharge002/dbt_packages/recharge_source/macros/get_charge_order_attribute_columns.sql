
{% macro get_charge_order_attribute_columns() %}

{% set columns = [
    {"name": "charge_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_attribute", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}