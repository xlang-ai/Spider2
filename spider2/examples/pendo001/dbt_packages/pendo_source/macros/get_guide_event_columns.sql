{% macro get_guide_event_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "app_id", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "element_path", "datatype": dbt.type_string()},
    {"name": "guide_id", "datatype": dbt.type_string()},
    {"name": "guide_step_id", "datatype": dbt.type_string()},
    {"name": "latitude", "datatype": dbt.type_float()},
    {"name": "load_time", "datatype": dbt.type_int()},
    {"name": "longitude", "datatype": dbt.type_float()},
    {"name": "region", "datatype": dbt.type_string()},
    {"name": "remote_ip", "datatype": dbt.type_string()},
    {"name": "server_name", "datatype": dbt.type_string()},
    {"name": "timestamp", "datatype": dbt.type_timestamp()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "url", "datatype": dbt.type_string()},
    {"name": "user_agent", "datatype": dbt.type_string()},
    {"name": "visitor_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
