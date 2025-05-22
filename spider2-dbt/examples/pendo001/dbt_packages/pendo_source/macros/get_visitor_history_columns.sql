{% macro get_visitor_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "first_visit", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "id_hash", "datatype": dbt.type_int()},
    {"name": "last_browser_name", "datatype": dbt.type_string()},
    {"name": "last_browser_version", "datatype": dbt.type_string()},
    {"name": "last_operating_system", "datatype": dbt.type_string()},
    {"name": "last_server_name", "datatype": dbt.type_string()},
    {"name": "last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "last_user_agent", "datatype": dbt.type_string()},
    {"name": "last_visit", "datatype": dbt.type_timestamp()},
    {"name": "n_id", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('pendo__visitor_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
