{% macro get_email_template_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "folder_folder_name", "datatype": dbt.type_string()},
    {"name": "folder_id", "datatype": dbt.type_int()},
    {"name": "folder_type", "datatype": dbt.type_string()},
    {"name": "folder_value", "datatype": dbt.type_int()},
    {"name": "from_email", "datatype": dbt.type_string()},
    {"name": "from_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "operational", "datatype": "boolean"},
    {"name": "program_id", "datatype": dbt.type_int()},
    {"name": "publish_to_msi", "datatype": "boolean"},
    {"name": "reply_email", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "template", "datatype": dbt.type_int()},
    {"name": "text_only", "datatype": "boolean"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "url", "datatype": dbt.type_string()},
    {"name": "version", "datatype": dbt.type_int()},
    {"name": "web_view", "datatype": "boolean"},
    {"name": "workspace", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
