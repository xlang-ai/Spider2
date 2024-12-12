{% macro get_email_event_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "caused_by_created", "datatype": dbt.type_timestamp()},
    {"name": "caused_by_id", "datatype": dbt.type_string()},
    {"name": "created", "datatype": dbt.type_timestamp()},
    {"name": "email_campaign_id", "datatype": dbt.type_int()},
    {"name": "filtered_event", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "obsoleted_by_created", "datatype": dbt.type_timestamp()},
    {"name": "obsoleted_by_id", "datatype": dbt.type_string()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "recipient", "datatype": dbt.type_string()},
    {"name": "sent_by_created", "datatype": dbt.type_timestamp()},
    {"name": "sent_by_id", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
