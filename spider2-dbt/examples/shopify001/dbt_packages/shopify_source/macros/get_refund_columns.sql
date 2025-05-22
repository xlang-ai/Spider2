{% macro get_refund_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_numeric()},
    {"name": "note", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_numeric()},
    {"name": "processed_at", "datatype": dbt.type_timestamp()},
    {"name": "restock", "datatype": "boolean"},
    {"name": "total_duties_set", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_numeric()}
] %}

{{ return(columns) }}

{% endmacro %}