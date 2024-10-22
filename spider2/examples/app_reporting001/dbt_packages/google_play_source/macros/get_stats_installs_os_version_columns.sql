{% macro get_stats_installs_os_version_columns() %}

{% set columns = [
    {"name": "_file", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_line", "datatype": dbt.type_int()},
    {"name": "_modified", "datatype": dbt.type_timestamp()},
    {"name": "active_device_installs", "datatype": dbt.type_int()},
    {"name": "android_os_version", "datatype": dbt.type_string()},
    {"name": "current_device_installs", "datatype": dbt.type_int()},
    {"name": "current_user_installs", "datatype": dbt.type_int()},
    {"name": "daily_device_installs", "datatype": dbt.type_int()},
    {"name": "daily_device_uninstalls", "datatype": dbt.type_int()},
    {"name": "daily_device_upgrades", "datatype": dbt.type_int()},
    {"name": "daily_user_installs", "datatype": dbt.type_int()},
    {"name": "daily_user_uninstalls", "datatype": dbt.type_int()},
    {"name": "date", "datatype": "date"},
    {"name": "install_events", "datatype": dbt.type_int()},
    {"name": "package_name", "datatype": dbt.type_string()},
    {"name": "total_user_installs", "datatype": dbt.type_int()},
    {"name": "uninstall_events", "datatype": dbt.type_int()},
    {"name": "update_events", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
