{% macro get_usage_device_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active_devices", "datatype": dbt.type_int()},
    {"name": "active_devices_last_30_days", "datatype": dbt.type_int()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "deletions", "datatype": dbt.type_int()},
    {"name": "device", "datatype": dbt.type_string()},
    {"name": "installations", "datatype": dbt.type_int()},
    {"name": "meets_threshold", "datatype": "boolean"},
    {"name": "sessions", "datatype": dbt.type_int()},
    {"name": "source_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
