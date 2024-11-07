{% macro get_journal_entry_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "billable_status", "datatype": dbt.type_string()},
    {"name": "class_id", "datatype": dbt.type_string()},
    {"name": "customer_id", "datatype": dbt.type_string()},
    {"name": "department_id", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "description_service_date", "datatype": "date"},
    {"name": "description_tax_code_id", "datatype": dbt.type_string()},
    {"name": "employee_id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_string()},
    {"name": "journal_entry_id", "datatype": dbt.type_string()},
    {"name": "posting_type", "datatype": dbt.type_string()},
    {"name": "tax_amount", "datatype": dbt.type_float()},
    {"name": "tax_applicable_on", "datatype": dbt.type_string()},
    {"name": "tax_code_id", "datatype": dbt.type_string()},
    {"name": "vendor_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
