
{% macro get_address_shipping_line_columns() %}

{% set columns = [
    {"name": "address_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "price", "datatype": dbt.type_string()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}