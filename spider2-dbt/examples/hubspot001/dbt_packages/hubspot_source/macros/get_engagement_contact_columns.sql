{% macro get_engagement_contact_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "contact_id", "datatype": dbt.type_int()},
    {"name": "engagement_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
