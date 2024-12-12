{% macro get_directory_contact_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "directory_id", "datatype": dbt.type_string()},
    {"name": "directory_unsubscribe_date", "datatype": dbt.type_timestamp()},
    {"name": "directory_unsubscribed", "datatype": "boolean"},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "email_domain", "datatype": dbt.type_string()},
    {"name": "ext_ref", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "language", "datatype": dbt.type_string()},
    {"name": "last_modified", "datatype": dbt.type_timestamp()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "phone", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('qualtrics__directory_contact_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
