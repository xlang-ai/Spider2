{% macro get_price_rule_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "allocation_limit", "datatype": dbt.type_int()},
    {"name": "allocation_method", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "customer_selection", "datatype": dbt.type_string()},
    {"name": "ends_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "once_per_customer", "datatype": "boolean"},
    {"name": "prerequisite_quantity_range", "datatype": dbt.type_float()},
    {"name": "prerequisite_shipping_price_range", "datatype": dbt.type_float()},
    {"name": "prerequisite_subtotal_range", "datatype": dbt.type_float()},
    {"name": "prerequisite_to_entitlement_purchase_prerequisite_amount", "datatype": dbt.type_float()},
    {"name": "quantity_ratio_entitled_quantity", "datatype": dbt.type_int()},
    {"name": "quantity_ratio_prerequisite_quantity", "datatype": dbt.type_int()},
    {"name": "starts_at", "datatype": dbt.type_timestamp()},
    {"name": "target_selection", "datatype": dbt.type_string()},
    {"name": "target_type", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "usage_limit", "datatype": dbt.type_int()},
    {"name": "value", "datatype": dbt.type_float()},
    {"name": "value_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
