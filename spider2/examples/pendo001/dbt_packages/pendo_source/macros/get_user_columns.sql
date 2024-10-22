{% macro get_user_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "deleted_at", "datatype": dbt.type_timestamp()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "role", "datatype": dbt.type_int()},
    {"name": "user_type", "datatype": dbt.type_string()},
    {"name": "username", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
