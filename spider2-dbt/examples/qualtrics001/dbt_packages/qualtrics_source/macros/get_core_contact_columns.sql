{% macro get_core_contact_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "mailing_list_id", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "external_data_reference", "datatype": dbt.type_string()},
    {"name": "language", "datatype": dbt.type_string()},
    {"name": "unsubscribed", "datatype": "boolean"},
    {"name": "_fivetran_deleted", "datatype": "boolean"}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('qualtrics__core_contact_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
