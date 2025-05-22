{% macro get_activity_merge_leads_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "activity_date", "datatype": dbt.type_timestamp()},
    {"name": "activity_type_id", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "lead_id", "datatype": dbt.type_int()},
    {"name": "master_updated", "datatype": "boolean"},
    {"name": "merge_ids", "datatype": dbt.type_string()},
    {"name": "merge_source", "datatype": dbt.type_string()},
    {"name": "merged_in_sales", "datatype": "boolean"},
    {"name": "primary_attribute_value", "datatype": dbt.type_string()},
    {"name": "primary_attribute_value_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
