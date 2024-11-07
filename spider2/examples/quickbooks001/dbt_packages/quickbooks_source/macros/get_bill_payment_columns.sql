{% macro get_bill_payment_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "check_bank_account_id", "datatype": dbt.type_string()},
    {"name": "check_print_status", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "credit_card_account_id", "datatype": dbt.type_string()},
    {"name": "currency_id", "datatype": dbt.type_string()},
    {"name": "department_id", "datatype": dbt.type_string()},
    {"name": "doc_number", "datatype": dbt.type_string()},
    {"name": "exchange_rate", "datatype": dbt.type_float()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "pay_type", "datatype": dbt.type_string()},
    {"name": "payable_account_id", "datatype": dbt.type_string()},
    {"name": "private_note", "datatype": dbt.type_string()},
    {"name": "process_bill_payment", "datatype": "boolean"},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "total_amount", "datatype": dbt.type_float()},
    {"name": "transaction_date", "datatype": "date"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "vendor_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
