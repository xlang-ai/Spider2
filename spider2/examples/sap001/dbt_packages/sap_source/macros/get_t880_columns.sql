{% macro get_t880_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_rowid", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "city", "datatype": dbt.type_string()},
    {"name": "cntry", "datatype": dbt.type_string()},
    {"name": "curr", "datatype": dbt.type_string()},
    {"name": "glsip", "datatype": dbt.type_string()},
    {"name": "indpo", "datatype": dbt.type_string()},
    {"name": "langu", "datatype": dbt.type_string()},
    {"name": "lccomp", "datatype": dbt.type_string()},
    {"name": "mandt", "datatype": dbt.type_string()},
    {"name": "mclnt", "datatype": dbt.type_string()},
    {"name": "mcomp", "datatype": dbt.type_string()},
    {"name": "modcp", "datatype": dbt.type_string()},
    {"name": "name1", "datatype": dbt.type_string()},
    {"name": "name2", "datatype": dbt.type_string()},
    {"name": "pobox", "datatype": dbt.type_string()},
    {"name": "pstlc", "datatype": dbt.type_string()},
    {"name": "rcomp", "datatype": dbt.type_string()},
    {"name": "resta", "datatype": dbt.type_string()},
    {"name": "rform", "datatype": dbt.type_string()},
    {"name": "stret", "datatype": dbt.type_string()},
    {"name": "strt2", "datatype": dbt.type_string()},
    {"name": "zweig", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}