{% macro get_purchase_order_linked_txn_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "bill_id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_string()},
    {"name": "purchase_id", "datatype": dbt.type_string()},
    {"name": "purchase_order_id", "datatype": dbt.type_string()},
    {"name": "vendor_credit_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
