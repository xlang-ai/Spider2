{% macro get_feature_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_string()},
    {"name": "color", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by_user_id", "datatype": dbt.type_string()},
    {"name": "dirty", "datatype": "boolean"},
    {"name": "group_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_core_event", "datatype": "boolean"},
    {"name": "last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "last_updated_by_user_id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "page_id", "datatype": dbt.type_string()},
    {"name": "root_version_id", "datatype": dbt.type_string()},
    {"name": "stable_version_id", "datatype": dbt.type_string()},
    {"name": "valid_through", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
