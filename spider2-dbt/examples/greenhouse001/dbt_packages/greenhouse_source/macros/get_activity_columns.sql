{% macro get_activity_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "body", "datatype": dbt.type_string()},
    {"name": "candidate_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
