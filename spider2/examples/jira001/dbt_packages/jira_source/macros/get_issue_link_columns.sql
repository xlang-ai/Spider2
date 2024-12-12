{% macro get_issue_link_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "issue_id", "datatype": dbt.type_int()},
    {"name": "related_issue_id", "datatype": dbt.type_int()},
    {"name": "relationship", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}