
{% macro get_one_time_product_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "address_id", "datatype": dbt.type_int()},
    {"name": "customer_id", "datatype": dbt.type_int()},
    {"name": "is_deleted", "datatype": dbt.type_boolean()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "next_charge_scheduled_at", "datatype": dbt.type_timestamp()},
    {"name": "product_title", "datatype": dbt.type_string()},
    {"name": "variant_title", "datatype": dbt.type_string()},
    {"name": "price", "datatype": dbt.type_int()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "external_product_id_ecommerce", "datatype": dbt.type_int()},
    {"name": "external_variant_id_ecommerce", "datatype": dbt.type_int()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}