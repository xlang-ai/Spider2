{% macro get_contact_tag_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_string()},
    {"name": "_fivetran_active", "datatype": "boolean"},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "contact_id", "datatype": dbt.type_string()},
    {"name": "contact_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "tag_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
