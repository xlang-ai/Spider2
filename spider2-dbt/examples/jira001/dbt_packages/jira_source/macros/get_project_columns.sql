{% macro get_project_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "key", "datatype": dbt.type_string()},
    {"name": "lead_id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "permission_scheme_id", "datatype": dbt.type_int()},
    {"name": "project_category_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
