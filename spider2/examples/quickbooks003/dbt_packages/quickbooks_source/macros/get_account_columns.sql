{% macro get_account_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_number", "datatype": dbt.type_string()},
    {"name": "account_sub_type", "datatype": dbt.type_string()},
    {"name": "account_type", "datatype": dbt.type_string()},
    {"name": "active", "datatype": "boolean"},
    {"name": "balance", "datatype": dbt.type_float()},
    {"name": "balance_with_sub_accounts", "datatype": dbt.type_float()},
    {"name": "classification", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "currency_id", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "fully_qualified_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "parent_account_id", "datatype": dbt.type_string()},
    {"name": "sub_account", "datatype": "boolean"},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "tax_code_id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
