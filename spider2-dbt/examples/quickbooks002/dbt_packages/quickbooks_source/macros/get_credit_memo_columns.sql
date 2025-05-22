{% macro get_credit_memo_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "apply_tax_after_discount", "datatype": "boolean"},
    {"name": "balance", "datatype": dbt.type_float()},
    {"name": "bill_email", "datatype": dbt.type_string()},
    {"name": "billing_address_id", "datatype": dbt.type_string()},
    {"name": "class_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "currency_id", "datatype": dbt.type_string()},
    {"name": "custom_p_o_number", "datatype": dbt.type_string()},
    {"name": "customer_id", "datatype": dbt.type_string()},
    {"name": "customer_memo", "datatype": dbt.type_string()},
    {"name": "department_id", "datatype": dbt.type_string()},
    {"name": "doc_number", "datatype": dbt.type_string()},
    {"name": "email_status", "datatype": dbt.type_string()},
    {"name": "exchange_rate", "datatype": dbt.type_float()},
    {"name": "global_tax_calculation", "datatype": dbt.type_string()},
    {"name": "home_balance", "datatype": dbt.type_float()},
    {"name": "home_total_amount", "datatype": dbt.type_float()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "payment_method_id", "datatype": dbt.type_string()},
    {"name": "print_status", "datatype": dbt.type_string()},
    {"name": "private_note", "datatype": dbt.type_string()},
    {"name": "remaining_credit", "datatype": dbt.type_float()},
    {"name": "sales_term_id", "datatype": dbt.type_string()},
    {"name": "shipping_address_id", "datatype": dbt.type_string()},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "total_amount", "datatype": dbt.type_float()},
    {"name": "total_tax", "datatype": dbt.type_string()},
    {"name": "transaction_date", "datatype": "date"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}