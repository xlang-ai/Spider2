
{% macro get_charge_line_item_columns() %}

{% set columns = [
    {"name": "charge_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "variant_title", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "grams", "datatype": dbt.type_float()},
    {"name": "total_price", "datatype": dbt.type_float()},
    {"name": "unit_price", "datatype": dbt.type_float()},
    {"name": "tax_due", "datatype": dbt.type_float()},
    {"name": "taxable", "datatype": dbt.type_boolean()},
    {"name": "taxable_amount", "datatype": dbt.type_float()},
    {"name": "unit_price_includes_tax", "datatype": dbt.type_boolean()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "external_product_id_ecommerce", "datatype": dbt.type_int()},
    {"name": "external_variant_id_ecommerce", "datatype": dbt.type_int()},
    {"name": "vendor", "datatype": dbt.type_string()},
    {"name": "purchase_item_id", "datatype": dbt.type_int()},
    {"name": "purchase_item_type", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('recharge__charge_line_item_passthrough_columns')) }}

{{ return(columns) }}

{% endmacro %}