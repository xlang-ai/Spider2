{% macro get_purchase_order_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_expense_account_id", "datatype": dbt.type_string()},
    {"name": "account_expense_billable_status", "datatype": dbt.type_string()},
    {"name": "account_expense_class_id", "datatype": dbt.type_string()},
    {"name": "account_expense_customer_id", "datatype": dbt.type_string()},
    {"name": "account_expense_tax_amount", "datatype": dbt.type_float()},
    {"name": "account_expense_tax_code_id", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_string()},
    {"name": "item_expense_billable_status", "datatype": dbt.type_string()},
    {"name": "item_expense_class_id", "datatype": dbt.type_string()},
    {"name": "item_expense_customer_id", "datatype": dbt.type_string()},
    {"name": "item_expense_item_id", "datatype": dbt.type_string()},
    {"name": "item_expense_quantity", "datatype": dbt.type_float()},
    {"name": "item_expense_tax_code_id", "datatype": dbt.type_string()},
    {"name": "item_expense_unit_price", "datatype": dbt.type_float()},
    {"name": "purchase_order_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
