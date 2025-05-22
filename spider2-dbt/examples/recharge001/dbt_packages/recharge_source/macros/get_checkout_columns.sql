
{% macro get_checkout_columns() %}

{% set columns = [
    {"name": "token", "datatype": dbt.type_string()},
    {"name": "charge_id", "datatype": dbt.type_int()},
    {"name": "buyer_accepts_marketing", "datatype": dbt.type_boolean()},
    {"name": "completed_at", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "discount_code", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "external_checkout_id", "datatype": dbt.type_string()},
    {"name": "external_checkout_source", "datatype": dbt.type_string()},
    {"name": "external_transaction_id_payment_processor", "datatype": dbt.type_string()},
    {"name": "order_attributes", "datatype": dbt.type_string()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "requires_shipping", "datatype": dbt.type_boolean()},
    {"name": "subtotal_price", "datatype": dbt.type_float()},
    {"name": "taxes_included", "datatype": dbt.type_boolean()},
    {"name": "total_price", "datatype": dbt.type_float()},
    {"name": "total_tax", "datatype": dbt.type_float()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}