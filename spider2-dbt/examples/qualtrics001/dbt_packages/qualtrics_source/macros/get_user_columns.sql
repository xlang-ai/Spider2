{% macro get_user_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_creation_date", "datatype": dbt.type_timestamp()},
    {"name": "account_expiration_date", "datatype": dbt.type_timestamp()},
    {"name": "account_status", "datatype": dbt.type_string()},
    {"name": "division_id", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "language", "datatype": dbt.type_string()},
    {"name": "last_login_date", "datatype": dbt.type_timestamp()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "organization_id", "datatype": dbt.type_string()},
    {"name": "password_expiration_date", "datatype": dbt.type_timestamp()},
    {"name": "password_last_changed_date", "datatype": dbt.type_timestamp()},
    {"name": "response_count_auditable", "datatype": dbt.type_int()},
    {"name": "response_count_deleted", "datatype": dbt.type_int()},
    {"name": "response_count_generated", "datatype": dbt.type_int()},
    {"name": "time_zone", "datatype": dbt.type_string()},
    {"name": "unsubscribed", "datatype": "boolean"},
    {"name": "user_type", "datatype": dbt.type_string()},
    {"name": "username", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
