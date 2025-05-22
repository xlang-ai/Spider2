{% macro get_survey_response_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "distribution_channel", "datatype": dbt.type_string()},
    {"name": "duration_in_seconds", "datatype": dbt.type_int()},
    {"name": "end_date", "datatype": dbt.type_timestamp()},
    {"name": "finished", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "ip_address", "datatype": dbt.type_string()},
    {"name": "last_modified_date", "datatype": dbt.type_timestamp()},
    {"name": "location_latitude", "datatype": dbt.type_float()},
    {"name": "location_longitude", "datatype": dbt.type_float()},
    {"name": "progress", "datatype": dbt.type_int()},
    {"name": "recipient_email", "datatype": dbt.type_string()},
    {"name": "recipient_first_name", "datatype": dbt.type_string()},
    {"name": "recipient_last_name", "datatype": dbt.type_string()},
    {"name": "recorded_date", "datatype": dbt.type_timestamp()},
    {"name": "start_date", "datatype": dbt.type_timestamp()},
    {"name": "status", "datatype": dbt.type_int()},
    {"name": "survey_id", "datatype": dbt.type_string()},
    {"name": "user_language", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
