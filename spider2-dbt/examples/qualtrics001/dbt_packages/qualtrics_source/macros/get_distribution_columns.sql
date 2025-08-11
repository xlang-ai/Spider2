{% macro get_distribution_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "header_from_email", "datatype": dbt.type_string()},
    {"name": "header_from_name", "datatype": dbt.type_string()},
    {"name": "header_reply_to_email", "datatype": dbt.type_string()},
    {"name": "header_subject", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "message_library_id", "datatype": dbt.type_string()},
    {"name": "message_message_id", "datatype": dbt.type_string()},
    {"name": "message_message_text", "datatype": dbt.type_string()},
    {"name": "modified_date", "datatype": dbt.type_timestamp()},
    {"name": "organization_id", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "parent_distribution_id", "datatype": dbt.type_string()},
    {"name": "recipient_contact_id", "datatype": dbt.type_string()},
    {"name": "recipient_library_id", "datatype": dbt.type_string()},
    {"name": "recipient_mailing_list_id", "datatype": dbt.type_string()},
    {"name": "recipient_sample_id", "datatype": dbt.type_string()},
    {"name": "request_status", "datatype": dbt.type_string()},
    {"name": "request_type", "datatype": dbt.type_string()},
    {"name": "send_date", "datatype": dbt.type_timestamp()},
    {"name": "survey_link_expiration_date", "datatype": dbt.type_timestamp()},
    {"name": "survey_link_link_type", "datatype": dbt.type_string()},
    {"name": "survey_link_survey_id", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('qualtrics__distribution_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
