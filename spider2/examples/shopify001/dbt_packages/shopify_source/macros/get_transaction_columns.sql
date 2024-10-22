{% macro get_transaction_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_numeric()},
    {"name": "order_id", "datatype": dbt.type_numeric()},
    {"name": "refund_id", "datatype": dbt.type_numeric()},
    {"name": "amount", "datatype": dbt.type_numeric()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "processed_at", "datatype": dbt.type_timestamp()},
    {"name": "device_id", "datatype": dbt.type_numeric()},
    {"name": "gateway", "datatype": dbt.type_string()},
    {"name": "source_name", "datatype": dbt.type_string()},
    {"name": "message", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "location_id", "datatype": dbt.type_numeric()},
    {"name": "parent_id", "datatype": dbt.type_numeric()},
    {"name": "payment_avs_result_code", "datatype": dbt.type_string()},
    {"name": "payment_credit_card_bin", "datatype": dbt.type_string()},
    {"name": "payment_cvv_result_code", "datatype": dbt.type_string()},
    {"name": "payment_credit_card_number", "datatype": dbt.type_string()},
    {"name": "payment_credit_card_company", "datatype": dbt.type_string()},
    {"name": "kind", "datatype": dbt.type_string()},
    {"name": "receipt", "datatype": dbt.type_string()},
    {"name": "currency_exchange_id", "datatype": dbt.type_numeric()},
    {"name": "currency_exchange_adjustment", "datatype": dbt.type_numeric()},
    {"name": "currency_exchange_original_amount", "datatype": dbt.type_numeric()},
    {"name": "currency_exchange_final_amount", "datatype": dbt.type_numeric()},
    {"name": "currency_exchange_currency", "datatype": dbt.type_string()},
    {"name": "error_code", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "test", "datatype": "boolean"},
    {"name": "user_id", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "authorization_expires_at", "datatype": dbt.type_timestamp()}
] %}

{% if target.type in ('redshift','postgres') %}
 {{ columns.append({"name": "authorization", "datatype": dbt.type_string(), "quote": True, "alias": "authorization_code"}) }}
{% else %}
 {{ columns.append({"name": "authorization", "datatype": dbt.type_string(), "alias": "authorization_code"}) }}
{% endif %}

{{ return(columns) }}

{% endmacro %}