{% macro get_collection_product_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "collection_id", "datatype": dbt.type_int()},
    {"name": "product_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
