{% macro get_order_adjustment_columns() %}

{% set columns = [
    {"name": "id", "datatype":  dbt.type_numeric()},
    {"name": "order_id", "datatype":  dbt.type_numeric()},
    {"name": "refund_id", "datatype":  dbt.type_numeric()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "amount_set", "datatype": dbt.type_string()},
    {"name": "tax_amount", "datatype": dbt.type_float()},
    {"name": "tax_amount_set", "datatype": dbt.type_string()},
    {"name": "kind", "datatype": dbt.type_string()},
    {"name": "reason", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}