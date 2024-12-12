{% macro get_email_campaign_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "app_name", "datatype": dbt.type_string()},
    {"name": "content_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "num_included", "datatype": dbt.type_int()},
    {"name": "num_queued", "datatype": dbt.type_int()},
    {"name": "sub_type", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
