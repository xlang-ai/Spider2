{% macro get_office_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "external_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "location_name", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "parent_id", "datatype": dbt.type_int()},
    {"name": "primary_contact_user_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
