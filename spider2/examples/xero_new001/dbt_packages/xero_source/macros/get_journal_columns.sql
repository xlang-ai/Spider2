{% macro get_journal_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_date_utc", "datatype": dbt.type_timestamp()},
    {"name": "journal_date", "datatype": "date"},
    {"name": "journal_id", "datatype": dbt.type_string()},
    {"name": "journal_number", "datatype": dbt.type_int()},
    {"name": "reference", "datatype": dbt.type_string()},
    {"name": "source_id", "datatype": dbt.type_string()},
    {"name": "source_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
