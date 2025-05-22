{% macro get_ad_group_criterion_history_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "ad_group_id", "datatype": dbt.type_int()},
    {"name": "base_campaign_id", "datatype": dbt.type_int()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "keyword_match_type", "datatype": dbt.type_string()},
    {"name": "keyword_text", "datatype": dbt.type_string()},
    {"name": "_fivetran_active", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
