{% macro get_user_email_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
