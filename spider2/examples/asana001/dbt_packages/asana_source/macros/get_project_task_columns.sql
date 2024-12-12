{% macro get_project_task_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "project_id", "datatype": dbt.type_string()},
    {"name": "task_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
