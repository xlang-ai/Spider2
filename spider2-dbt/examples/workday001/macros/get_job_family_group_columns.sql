{% macro get_job_family_group_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "effective_date", "datatype": "date"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "inactive", "datatype": dbt.type_boolean()},
    {"name": "job_family_group_code", "datatype": dbt.type_string()},
    {"name": "summary", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
