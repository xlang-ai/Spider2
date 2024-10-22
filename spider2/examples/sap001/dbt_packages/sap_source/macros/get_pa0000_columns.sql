{% macro get_pa0000_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_rowid", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "aedtm", "datatype": dbt.type_string()},
    {"name": "begda", "datatype": dbt.type_string()},
    {"name": "endda", "datatype": dbt.type_string()},
    {"name": "flag1", "datatype": dbt.type_string()},
    {"name": "flag2", "datatype": dbt.type_string()},
    {"name": "flag3", "datatype": dbt.type_string()},
    {"name": "flag4", "datatype": dbt.type_string()},
    {"name": "grpvl", "datatype": dbt.type_string()},
    {"name": "histo", "datatype": dbt.type_string()},
    {"name": "itbld", "datatype": dbt.type_string()},
    {"name": "itxex", "datatype": dbt.type_string()},
    {"name": "mandt", "datatype": dbt.type_string()},
    {"name": "massg", "datatype": dbt.type_string()},
    {"name": "massn", "datatype": dbt.type_string()},
    {"name": "objps", "datatype": dbt.type_string()},
    {"name": "ordex", "datatype": dbt.type_string()},
    {"name": "pernr", "datatype": dbt.type_string()},
    {"name": "preas", "datatype": dbt.type_string()},
    {"name": "refex", "datatype": dbt.type_string()},
    {"name": "rese1", "datatype": dbt.type_string()},
    {"name": "rese2", "datatype": dbt.type_string()},
    {"name": "seqnr", "datatype": dbt.type_string()},
    {"name": "sprps", "datatype": dbt.type_string()},
    {"name": "stat1", "datatype": dbt.type_string()},
    {"name": "stat2", "datatype": dbt.type_string()},
    {"name": "stat3", "datatype": dbt.type_string()},
    {"name": "subty", "datatype": dbt.type_string()},
    {"name": "uname", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}