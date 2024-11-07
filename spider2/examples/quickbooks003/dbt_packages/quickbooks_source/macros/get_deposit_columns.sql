{% macro get_deposit_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "cash_back_account_id", "datatype": dbt.type_string()},
    {"name": "cash_back_amount", "datatype": dbt.type_float()},
    {"name": "cash_back_memo", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "currency_id", "datatype": dbt.type_string()},
    {"name": "department_id", "datatype": dbt.type_string()},
    {"name": "global_tax_calculation", "datatype": dbt.type_string()},
    {"name": "home_total_amount", "datatype": dbt.type_float()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "private_note", "datatype": dbt.type_string()},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "total_amount", "datatype": dbt.type_float()},
    {"name": "transaction_date", "datatype": "date"},
    {"name": "transaction_source", "datatype": dbt.type_string()},
    {"name": "transaction_status", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
