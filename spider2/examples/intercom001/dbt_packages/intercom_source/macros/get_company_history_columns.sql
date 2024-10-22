{% macro get_company_history_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": "boolean"},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "industry", "datatype": dbt.type_int()},
    {"name": "monthly_spend", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "plan_id", "datatype": dbt.type_int()},
    {"name": "plan_name", "datatype": dbt.type_int()},
    {"name": "session_count", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "user_count", "datatype": dbt.type_int()},
    {"name": "website", "datatype": dbt.type_int()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('intercom__company_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
