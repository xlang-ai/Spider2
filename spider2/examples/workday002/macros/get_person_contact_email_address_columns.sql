{% macro get_person_contact_email_address_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "email_address", "datatype": dbt.type_string()},
    {"name": "email_code", "datatype": dbt.type_string()},
    {"name": "email_comment", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
