{% macro get_invoice_line_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_code", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "discount_entered_as_percent", "datatype": "boolean"},
    {"name": "discount_rate", "datatype": dbt.type_int()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "item_code", "datatype": dbt.type_string()},
    {"name": "line_amount", "datatype": dbt.type_numeric()},
    {"name": "line_item_id", "datatype": dbt.type_string()},
    {"name": "quantity", "datatype": dbt.type_numeric()},
    {"name": "tax_amount", "datatype": dbt.type_numeric()},
    {"name": "tax_type", "datatype": dbt.type_string()},
    {"name": "unit_amount", "datatype": dbt.type_numeric()},
    {"name": "validation_errors", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
