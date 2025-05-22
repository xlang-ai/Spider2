{% macro get_contact_list_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "deleteable", "datatype": "boolean"},
    {"name": "dynamic", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "metadata_error", "datatype": dbt.type_string()},
    {"name": "metadata_last_processing_state_change_at", "datatype": dbt.type_timestamp()},
    {"name": "metadata_last_size_change_at", "datatype": dbt.type_timestamp()},
    {"name": "metadata_processing", "datatype": dbt.type_string()},
    {"name": "metadata_size", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
