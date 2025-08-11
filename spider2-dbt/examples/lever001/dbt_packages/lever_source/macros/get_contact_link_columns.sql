{% macro get_contact_link_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "contact_id", "datatype": dbt.type_string()},
    {"name": "link", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
