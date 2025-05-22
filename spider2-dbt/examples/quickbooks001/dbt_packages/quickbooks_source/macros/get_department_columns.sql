{% macro get_department_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "fully_qualified_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "parent_department_id", "datatype": dbt.type_string()},
    {"name": "sub_department", "datatype": "boolean"},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}