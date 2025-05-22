
{% macro get_subscription_history_columns() %}

{% set columns = [
    {"name": "subscription_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "address_id", "datatype": dbt.type_int()},
    {"name": "customer_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "cancelled_at", "datatype": dbt.type_timestamp()},
    {"name": "next_charge_scheduled_at", "datatype": dbt.type_timestamp()},
    {"name": "price", "datatype": dbt.type_string()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "cancellation_reason", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "cancellation_reason_comments", "datatype": dbt.type_string()},
    {"name": "product_title", "datatype": dbt.type_string()},
    {"name": "variant_title", "datatype": dbt.type_string()},
    {"name": "external_product_id_ecommerce", "datatype": dbt.type_string()},
    {"name": "external_variant_id_ecommerce", "datatype": dbt.type_string()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "order_interval_unit", "datatype": dbt.type_string()},
    {"name": "order_interval_frequency", "datatype": dbt.type_int()},
    {"name": "charge_interval_frequency", "datatype": dbt.type_int()},
    {"name": "order_day_of_week", "datatype": dbt.type_int()},
    {"name": "order_day_of_month", "datatype": dbt.type_int()},
    {"name": "expire_after_specific_number_of_charges", "datatype": dbt.type_int()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": "type_timestamp"}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('recharge__subscription_history_passthrough_columns')) }}

{{ return(columns) }}

{% endmacro %}