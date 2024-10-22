{% macro get_abandoned_checkout_shipping_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "carrier_identifier", "datatype": dbt.type_string()},
    {"name": "checkout_id", "datatype": dbt.type_int()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "delivery_category", "datatype": dbt.type_string()},
    {"name": "delivery_expectation_range", "datatype": dbt.type_string()},
    {"name": "delivery_expectation_range_max", "datatype": dbt.type_int()},
    {"name": "delivery_expectation_range_min", "datatype": dbt.type_int()},
    {"name": "delivery_expectation_type", "datatype": dbt.type_string()},
    {"name": "discounted_price", "datatype": dbt.type_float()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "price", "datatype": dbt.type_float()},
    {"name": "requested_fulfillment_service_id", "datatype": dbt.type_string()},
    {"name": "source", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
