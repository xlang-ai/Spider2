
{% macro get_order_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "customer_id", "datatype": dbt.type_int()},
    {"name": "address_id", "datatype": dbt.type_int()},
    {"name": "charge_id", "datatype": dbt.type_int()},
    {"name": "is_deleted", "datatype": dbt.type_boolean()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "transaction_id", "datatype": dbt.type_string()},
    {"name": "charge_status", "datatype": dbt.type_string()},
    {"name": "is_prepaid", "datatype": dbt.type_boolean()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "total_price", "datatype": dbt.type_float()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "external_order_id_ecommerce", "datatype": dbt.type_string()},
    {"name": "external_order_number_ecommerce", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "processed_at", "datatype": dbt.type_timestamp()},
    {"name": "scheduled_at", "datatype": dbt.type_timestamp()},
    {"name": "shipped_date", "datatype": dbt.type_timestamp()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('recharge__order_passthrough_columns')) }}

{{ return(columns) }}

{% endmacro %}