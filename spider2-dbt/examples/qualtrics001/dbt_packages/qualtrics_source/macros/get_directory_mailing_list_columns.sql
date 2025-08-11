{% macro get_directory_mailing_list_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "directory_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_modified_date", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
