{% macro get_feature_event_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "app_id", "datatype": dbt.type_string()},
    {"name": "feature_id", "datatype": dbt.type_string()},
    {"name": "num_events", "datatype": dbt.type_int()},
    {"name": "num_minutes", "datatype": dbt.type_int()},
    {"name": "remote_ip", "datatype": dbt.type_string()},
    {"name": "server_name", "datatype": dbt.type_string()},
    {"name": "timestamp", "datatype": dbt.type_timestamp()},
    {"name": "user_agent", "datatype": dbt.type_string()},
    {"name": "visitor_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_id", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('pendo__feature_event_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
