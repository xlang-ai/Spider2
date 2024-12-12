{% macro get_issue_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_original_estimate", "datatype": dbt.type_float()},
    {"name": "_remaining_estimate", "datatype": dbt.type_float()},
    {"name": "_time_spent", "datatype": dbt.type_float()},
    {"name": "assignee", "datatype": dbt.type_string()},
    {"name": "created", "datatype": dbt.type_timestamp()},
    {"name": "creator", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "due_date", "datatype": "date"},
    {"name": "environment", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "issue_type", "datatype": dbt.type_int()},
    {"name": "key", "datatype": dbt.type_string()},

    {"name": "original_estimate", "datatype": dbt.type_float()},
    {"name": "parent_id", "datatype": dbt.type_int()},
    {"name": "priority", "datatype": dbt.type_int()},
    {"name": "project", "datatype": dbt.type_int()},
    {"name": "remaining_estimate", "datatype": dbt.type_float()},
    {"name": "reporter", "datatype": dbt.type_string()},
    {"name": "resolution", "datatype": dbt.type_int()},
    {"name": "resolved", "datatype": dbt.type_timestamp()},
    {"name": "status", "datatype": dbt.type_int()},
    {"name": "status_category_changed", "datatype": dbt.type_timestamp()},
    {"name": "summary", "datatype": dbt.type_string()},
    {"name": "time_spent", "datatype": dbt.type_float()},
    {"name": "updated", "datatype": dbt.type_timestamp()},
    {"name": "work_ratio", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}
