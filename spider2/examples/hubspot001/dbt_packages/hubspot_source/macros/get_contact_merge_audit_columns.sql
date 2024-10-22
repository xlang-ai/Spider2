{% macro get_contact_merge_audit_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "canonical_vid", "datatype": dbt.type_int()},
    {"name": "contact_id", "datatype": dbt.type_string()},
    {"name": "entity_id", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "num_properties_moved", "datatype": dbt.type_int()},
    {"name": "timestamp", "datatype": dbt.type_timestamp()},
    {"name": "user_id", "datatype": dbt.type_string()},
    {"name": "vid_to_merge", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}