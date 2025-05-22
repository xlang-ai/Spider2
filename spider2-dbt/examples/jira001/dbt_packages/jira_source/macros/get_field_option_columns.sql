{% macro get_field_option_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "parent_id", "datatype": dbt.type_int()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}