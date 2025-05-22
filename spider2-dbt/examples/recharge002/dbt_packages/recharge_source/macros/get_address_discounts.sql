
{% macro get_address_discounts_columns() %}

{% set columns = [
    {"name": "address_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}