{% macro get_organization_ugc_post_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "organization_id", "datatype": dbt.type_int()},
    {"name": "ugc_post_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
