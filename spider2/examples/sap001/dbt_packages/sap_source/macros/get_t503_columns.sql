{% macro get_t503_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_rowid", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "abart", "datatype": dbt.type_string()},
    {"name": "abtyp", "datatype": dbt.type_string()},
    {"name": "aksta", "datatype": dbt.type_string()},
    {"name": "ansta", "datatype": dbt.type_string()},
    {"name": "antyp", "datatype": dbt.type_string()},
    {"name": "austa", "datatype": dbt.type_string()},
    {"name": "burkz", "datatype": dbt.type_string()},
    {"name": "inwid", "datatype": dbt.type_string()},
    {"name": "konty", "datatype": dbt.type_string()},
    {"name": "mandt", "datatype": dbt.type_string()},
    {"name": "molga", "datatype": dbt.type_string()},
    {"name": "persg", "datatype": dbt.type_string()},
    {"name": "persk", "datatype": dbt.type_string()},
    {"name": "trfkz", "datatype": dbt.type_string()},
    {"name": "typsz", "datatype": dbt.type_string()},
    {"name": "zeity", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}