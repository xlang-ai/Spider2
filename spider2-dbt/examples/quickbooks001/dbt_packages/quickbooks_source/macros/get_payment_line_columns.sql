{% macro get_payment_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "check_id", "datatype": dbt.type_string()},
    {"name": "credit_card_charge_id", "datatype": dbt.type_string()},
    {"name": "credit_card_credit_id", "datatype": dbt.type_string()},
    {"name": "credit_memo_id", "datatype": dbt.type_string()},
    {"name": "deposit_id", "datatype": dbt.type_string()},
    {"name": "expense_id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "journal_entry_id", "datatype": dbt.type_string()},
    {"name": "payment_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}