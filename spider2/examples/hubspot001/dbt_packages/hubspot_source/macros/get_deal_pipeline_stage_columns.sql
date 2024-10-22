{% macro get_deal_pipeline_stage_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "closed_won", "datatype": "boolean"},
    {"name": "display_order", "datatype": dbt.type_int()},
    {"name": "label", "datatype": dbt.type_string()},
    {"name": "pipeline_id", "datatype": dbt.type_string()},
    {"name": "probability", "datatype": dbt.type_float()},
    {"name": "stage_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
