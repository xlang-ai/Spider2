{% macro get_group_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_string()},
    {"name": "color", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by_user_id", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "last_updated_by_user_id", "datatype": dbt.type_string()},
    {"name": "length", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
