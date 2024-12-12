{% macro get_order_shipping_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "carrier_identifier", "datatype": dbt.type_string()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "delivery_category", "datatype": dbt.type_string()},
    {"name": "discounted_price", "datatype": dbt.type_float()},
    {"name": "discounted_price_set", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "price", "datatype": dbt.type_float()},
    {"name": "price_set", "datatype": dbt.type_string()},
    {"name": "requested_fulfillment_service_id", "datatype": dbt.type_string()},
    {"name": "source", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
