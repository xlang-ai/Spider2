{% macro get_hiring_team_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "job_id", "datatype": dbt.type_int()},
    {"name": "role", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
