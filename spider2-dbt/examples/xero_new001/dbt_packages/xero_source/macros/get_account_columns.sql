{% macro get_account_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "bank_account_number", "datatype": dbt.type_string()},
    {"name": "bank_account_type", "datatype": dbt.type_string()},
    {"name": "class", "datatype": dbt.type_string()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "currency_code", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "enable_payments_to_account", "datatype": "boolean"},
    {"name": "has_attachments", "datatype": "boolean"},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "reporting_code", "datatype": dbt.type_string()},
    {"name": "reporting_code_name", "datatype": dbt.type_string()},
    {"name": "show_in_expense_claims", "datatype": "boolean"},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "system_account", "datatype": dbt.type_string()},
    {"name": "tax_type", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_date_utc", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
