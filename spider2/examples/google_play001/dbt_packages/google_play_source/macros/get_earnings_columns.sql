{% macro get_earnings_columns() %}

{% set columns = [
    {"name": "_file", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_line", "datatype": dbt.type_int()},
    {"name": "_modified", "datatype": dbt.type_timestamp()},
    {"name": "amount_buyer_currency_", "datatype": dbt.type_float()},
    {"name": "amount_merchant_currency_", "datatype": dbt.type_float()},
    {"name": "base_plan_id", "datatype": dbt.type_string()},
    {"name": "buyer_country", "datatype": dbt.type_string()},
    {"name": "buyer_currency", "datatype": dbt.type_string()},
    {"name": "buyer_postal_code", "datatype": dbt.type_string()},
    {"name": "buyer_state", "datatype": dbt.type_string()},
    {"name": "currency_conversion_rate", "datatype": dbt.type_float()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "hardware", "datatype": dbt.type_string()},
    {"name": "merchant_currency", "datatype": dbt.type_string()},
    {"name": "offer_id", "datatype": dbt.type_string()},
    {"name": "product_id", "datatype": dbt.type_string()},
    {"name": "product_title", "datatype": dbt.type_string()},
    {"name": "product_type", "datatype": dbt.type_int()},
    {"name": "refund_type", "datatype": dbt.type_string()},
    {"name": "sku_id", "datatype": dbt.type_string()},
    {"name": "tax_type", "datatype": dbt.type_string()},
    {"name": "transaction_date", "datatype": dbt.type_string()},
    {"name": "transaction_time", "datatype": dbt.type_string()},
    {"name": "transaction_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
