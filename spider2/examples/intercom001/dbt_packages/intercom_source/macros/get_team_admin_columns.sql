{% macro get_team_admin_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "admin_id", "datatype": dbt.type_string()},
    {"name": "team_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
