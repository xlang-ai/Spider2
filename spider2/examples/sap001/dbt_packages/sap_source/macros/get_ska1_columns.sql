{% macro get_ska1_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_rowid", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "bilkt", "datatype": dbt.type_string()},
    {"name": "erdat", "datatype": dbt.type_string()},
    {"name": "ernam", "datatype": dbt.type_string()},
    {"name": "func_area", "datatype": dbt.type_string()},
    {"name": "gvtyp", "datatype": dbt.type_string()},
    {"name": "ktoks", "datatype": dbt.type_string()},
    {"name": "ktopl", "datatype": dbt.type_string()},
    {"name": "mandt", "datatype": dbt.type_string()},
    {"name": "mcod1", "datatype": dbt.type_string()},
    {"name": "mustr", "datatype": dbt.type_string()},
    {"name": "sakan", "datatype": dbt.type_string()},
    {"name": "saknr", "datatype": dbt.type_string()},
    {"name": "vbund", "datatype": dbt.type_string()},
    {"name": "xbilk", "datatype": dbt.type_string()},
    {"name": "xloev", "datatype": dbt.type_string()},
    {"name": "xspea", "datatype": dbt.type_string()},
    {"name": "xspeb", "datatype": dbt.type_string()},
    {"name": "xspep", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}