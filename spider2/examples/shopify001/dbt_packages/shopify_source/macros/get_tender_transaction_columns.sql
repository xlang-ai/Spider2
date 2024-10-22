{% macro get_tender_transaction_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "payment_method", "datatype": dbt.type_string()},
    {"name": "processed_at", "datatype": dbt.type_timestamp()},
    {"name": "remote_reference", "datatype": dbt.type_string()},
    {"name": "test", "datatype": "boolean"},
    {"name": "user_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
