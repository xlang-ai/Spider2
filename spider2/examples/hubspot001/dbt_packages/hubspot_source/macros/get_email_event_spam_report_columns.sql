{% macro get_email_event_spam_report_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "ip_address", "datatype": dbt.type_string()},
    {"name": "user_agent", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
