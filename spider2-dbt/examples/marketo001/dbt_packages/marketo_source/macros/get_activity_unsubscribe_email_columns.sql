{% macro get_activity_unsubscribe_email_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "activity_date", "datatype": dbt.type_timestamp()},
    {"name": "activity_type_id", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "campaign_run_id", "datatype": dbt.type_int()},
    {"name": "client_ip_address", "datatype": dbt.type_string()},
    {"name": "email_template_id", "datatype": dbt.type_int()},
    {"name": "form_fields", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "lead_id", "datatype": dbt.type_int()},
    {"name": "primary_attribute_value", "datatype": dbt.type_string()},
    {"name": "primary_attribute_value_id", "datatype": dbt.type_int()},
    {"name": "query_parameters", "datatype": dbt.type_string()},
    {"name": "referrer_url", "datatype": dbt.type_string()},
    {"name": "test_variant", "datatype": dbt.type_int()},
    {"name": "user_agent", "datatype": dbt.type_string()},
    {"name": "webform_id", "datatype": dbt.type_int()},
    {"name": "webpage_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
