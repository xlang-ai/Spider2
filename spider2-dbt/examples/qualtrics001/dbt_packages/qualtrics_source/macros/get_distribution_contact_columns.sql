{% macro get_distribution_contact_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "contact_frequency_rule_id", "datatype": dbt.type_string()},
    {"name": "contact_id", "datatype": dbt.type_string()},
    {"name": "contact_lookup_id", "datatype": dbt.type_string()},
    {"name": "distribution_id", "datatype": dbt.type_string()},
    {"name": "opened_at", "datatype": dbt.type_timestamp()},
    {"name": "response_completed_at", "datatype": dbt.type_timestamp()},
    {"name": "response_id", "datatype": dbt.type_string()},
    {"name": "response_started_at", "datatype": dbt.type_timestamp()},
    {"name": "sent_at", "datatype": dbt.type_timestamp()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "survey_link", "datatype": dbt.type_string()},
    {"name": "survey_session_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
