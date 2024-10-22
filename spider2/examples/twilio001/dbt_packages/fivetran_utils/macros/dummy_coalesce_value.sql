{% macro dummy_coalesce_value(column) %}

{% set coalesce_value = {
 'STRING': "'DUMMY_STRING'",
 'BOOLEAN': 'null',
 'INT': 999999999,
 'FLOAT': 999999999.99,
 'TIMESTAMP': 'cast("2099-12-31" as timestamp)',
 'DATE': 'cast("2099-12-31" as date)',
} %}

{% if column.is_float() %}
{{ return(coalesce_value['FLOAT']) }}

{% elif column.is_numeric() %}
{{ return(coalesce_value['INT']) }}

{% elif column.is_string() %}
{{ return(coalesce_value['STRING']) }}

{% elif column.data_type|lower == 'boolean' %}
{{ return(coalesce_value['BOOLEAN']) }}

{% elif 'timestamp' in column.data_type|lower %}
{{ return(coalesce_value['TIMESTAMP']) }}

{% elif 'date' in column.data_type|lower %}
{{ return(coalesce_value['DATE']) }}

{% elif 'int' in column.data_type|lower %}
{{ return(coalesce_value['INT']) }}

{% endif %}


{% endmacro %}