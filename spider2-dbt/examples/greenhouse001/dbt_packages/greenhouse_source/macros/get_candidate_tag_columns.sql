{% macro get_candidate_tag_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "candidate_id", "datatype": dbt.type_int()},
    {"name": "tag_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
