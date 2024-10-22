{% macro get_conversation_part_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": "boolean"},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "assigned_to_id", "datatype": dbt.type_int()},
    {"name": "assigned_to_type", "datatype": dbt.type_string()},
    {"name": "author_id", "datatype": dbt.type_string()},
    {"name": "body", "datatype": dbt.type_string()},
    {"name": "author_type", "datatype": dbt.type_string()},
    {"name": "conversation_id", "datatype": dbt.type_int()},
    {"name": "conversation_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "part_type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
