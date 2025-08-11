{% macro get_account_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "approval_status", "datatype": dbt.type_string()},
    {"name": "business_id", "datatype": dbt.type_string()},
    {"name": "business_name", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "deleted", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "industry_type", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "salt", "datatype": dbt.type_string()},
    {"name": "timezone", "datatype": dbt.type_string()},
    {"name": "timezone_switch_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
