{% macro get_ticket_pipeline_stage_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "display_order", "datatype": dbt.type_int()},
    {"name": "is_closed", "datatype": "boolean"},
    {"name": "label", "datatype": dbt.type_string()},
    {"name": "pipeline_id", "datatype": dbt.type_string()},
    {"name": "stage_id", "datatype": dbt.type_string()},
    {"name": "ticket_state", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
