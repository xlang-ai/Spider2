{% macro get_organization_role_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "organization_id", "datatype": dbt.type_string()},
    {"name": "organization_role_code", "datatype": dbt.type_string()},
    {"name": "role_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
