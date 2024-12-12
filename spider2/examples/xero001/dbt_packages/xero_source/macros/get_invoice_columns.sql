{% macro get_invoice_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount_credited", "datatype": dbt.type_numeric()},
    {"name": "amount_due", "datatype": dbt.type_numeric()},
    {"name": "amount_paid", "datatype": dbt.type_numeric()},
    {"name": "branding_theme_id", "datatype": dbt.type_string()},
    {"name": "cisdeduction", "datatype": dbt.type_numeric()},
    {"name": "contact_id", "datatype": dbt.type_string()},
    {"name": "currency_code", "datatype": dbt.type_string()},
    {"name": "currency_rate", "datatype": dbt.type_numeric()},
    {"name": "date", "datatype": "date"},
    {"name": "due_date", "datatype": "date"},
    {"name": "expected_payment_date", "datatype": dbt.type_timestamp()},
    {"name": "fully_paid_on_date", "datatype": "date"},
    {"name": "has_attachments", "datatype": "boolean"},
    {"name": "has_errors", "datatype": "boolean"},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "invoice_number", "datatype": dbt.type_string()},
    {"name": "is_discounted", "datatype": "boolean"},
    {"name": "line_amount_types", "datatype": dbt.type_string()},
    {"name": "planned_payment_date", "datatype": dbt.type_timestamp()},
    {"name": "reference", "datatype": dbt.type_string()},
    {"name": "sent_to_contact", "datatype": "boolean"},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "sub_total", "datatype": dbt.type_numeric()},
    {"name": "total", "datatype": dbt.type_numeric()},
    {"name": "total_tax", "datatype": dbt.type_numeric()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_date_utc", "datatype": dbt.type_timestamp()},
    {"name": "url", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
