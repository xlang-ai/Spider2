{% macro get_source_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "source_type_id", "datatype": dbt.type_int()},
    {"name": "source_type_name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
