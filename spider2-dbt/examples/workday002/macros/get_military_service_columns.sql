{% macro get_military_service_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "discharge_date", "datatype": "date"},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "notes", "datatype": dbt.type_string()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()},
    {"name": "rank", "datatype": dbt.type_string()},
    {"name": "service", "datatype": dbt.type_string()},
    {"name": "service_type", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "status_begin_date", "datatype": "date"}
] %}

{{ return(columns) }}

{% endmacro %}
