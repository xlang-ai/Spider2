{% macro get_task_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "assignee_id", "datatype": dbt.type_string()},
    {"name": "completed", "datatype": "boolean"},
    {"name": "completed_at", "datatype": dbt.type_timestamp()},
    {"name": "completed_by_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "due_at", "datatype": dbt.type_timestamp()},
    {"name": "due_on", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "modified_at", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "liked", "datatype": "boolean"},
    {"name": "num_likes", "datatype": dbt.type_int()},
    {"name": "parent_id", "datatype": dbt.type_string()},
    {"name": "start_on", "datatype": dbt.type_timestamp()},
    {"name": "workspace_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
