{% macro get_customer_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "accepts_marketing", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "default_address_id", "datatype": dbt.type_numeric()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_numeric()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "orders_count", "datatype": dbt.type_numeric()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "tax_exempt", "datatype": "boolean"},
    {"name": "total_spent", "datatype": dbt.type_float()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "verified_email", "datatype": "boolean"},
    {"name": "email_marketing_consent_consent_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "email_marketing_consent_opt_in_level", "datatype": dbt.type_string()},
    {"name": "email_marketing_consent_state", "datatype": dbt.type_string()},
    {"name": "note", "datatype": dbt.type_string()},
    {"name": "accepts_marketing_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "marketing_opt_in_level", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('customer_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}