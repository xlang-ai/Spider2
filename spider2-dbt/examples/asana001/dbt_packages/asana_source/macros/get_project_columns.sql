{% macro get_project_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "archived", "datatype": "boolean"},
    {"name": "color", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "current_status", "datatype": dbt.type_string()},
    {"name": "due_date", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "modified_at", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "public", "datatype": "boolean"},
    {"name": "team_id", "datatype": dbt.type_string()},
    {"name": "workspace_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
