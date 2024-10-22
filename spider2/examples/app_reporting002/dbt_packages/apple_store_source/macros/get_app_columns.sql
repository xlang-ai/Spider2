{% macro get_app_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_opt_in_rate", "datatype": dbt.type_int()},
    {"name": "asset_token", "datatype": dbt.type_string()},
    {"name": "icon_url", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "ios", "datatype": "boolean"},
    {"name": "is_bundle", "datatype": "boolean"},
    {"name": "is_enabled", "datatype": "boolean"},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "pre_order_info", "datatype": dbt.type_string()},
    {"name": "tvos", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
