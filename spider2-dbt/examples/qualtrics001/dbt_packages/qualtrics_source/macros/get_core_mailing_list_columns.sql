{% macro get_core_mailing_list_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "library_id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "category", "datatype": dbt.type_string()},
    {"name": "folder", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
