{% macro get_organization_job_family_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "job_family_group_id", "datatype": dbt.type_string()},
    {"name": "job_family_id", "datatype": dbt.type_string()},
    {"name": "organization_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
