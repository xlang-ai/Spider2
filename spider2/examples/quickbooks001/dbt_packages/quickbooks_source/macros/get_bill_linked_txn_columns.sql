{% macro get_bill_linked_txn_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "bill_id", "datatype": dbt.type_string()},
    {"name": "bill_payment_id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
