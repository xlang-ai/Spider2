{% macro get_collection_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "disjunctive", "datatype": "boolean"},
    {"name": "handle", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "published_at", "datatype": dbt.type_timestamp()},
    {"name": "published_scope", "datatype": dbt.type_string()},
    {"name": "rules", "datatype": dbt.type_string()},
    {"name": "sort_order", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
