{% macro get_opportunity_stage_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "opportunity_id", "datatype": dbt.type_string()},
    {"name": "stage_id", "datatype": dbt.type_string()},
    {"name": "to_stage_index", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "updater_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
