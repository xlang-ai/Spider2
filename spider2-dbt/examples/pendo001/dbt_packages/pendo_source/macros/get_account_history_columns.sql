{% macro get_account_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "first_visit", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "id_hash", "datatype": dbt.type_int()},
    {"name": "last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "last_visit", "datatype": dbt.type_timestamp()},
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('pendo__account_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
