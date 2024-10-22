{% macro get_campaign_history_columns() %}

{% set columns = [
    {"name": "advertising_channel_subtype", "datatype": dbt.type_string()},
    {"name": "advertising_channel_type", "datatype": dbt.type_string()},
    {"name": "customer_id", "datatype": dbt.type_int()},
    {"name": "end_date", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "serving_status", "datatype": dbt.type_string()},
    {"name": "start_date", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "tracking_url_template", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}