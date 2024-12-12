{% macro get_order_url_tag_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "key", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
