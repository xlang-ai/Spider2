{% macro get_user_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "locale", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "time_zone", "datatype": dbt.type_string()},
    {"name": "username", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
