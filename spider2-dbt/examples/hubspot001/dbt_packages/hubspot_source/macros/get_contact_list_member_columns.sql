{% macro get_contact_list_member_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "added_at", "datatype": dbt.type_timestamp()},
    {"name": "contact_id", "datatype": dbt.type_int()},
    {"name": "contact_list_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
