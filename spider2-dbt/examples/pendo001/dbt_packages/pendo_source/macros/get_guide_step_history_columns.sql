{% macro get_guide_step_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "guide_id", "datatype": dbt.type_string()},
    {"name": "guide_last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "step_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
