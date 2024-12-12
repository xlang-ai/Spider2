{% macro get_order_shipping_tax_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_shipping_line_id", "datatype": dbt.type_int()},
    {"name": "price", "datatype": dbt.type_float()},
    {"name": "price_set", "datatype": dbt.type_string()},
    {"name": "rate", "datatype": dbt.type_float()},
    {"name": "title", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
