{% macro get_ticket_property_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "ticket_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string(), "alias": "field_name"},
    {"name": "source", "datatype": dbt.type_string(), "alias": "change_source"},
    {"name": "source_id", "datatype": dbt.type_string(), "alias": "change_source_id"},
    {"name": "timestamp_instant", "datatype": dbt.type_timestamp(), "alias": "change_timestamp"},
    {"name": "value", "datatype": dbt.type_string(), "alias": "new_value"}
] %}

{{ return(columns) }}

{% endmacro %}
