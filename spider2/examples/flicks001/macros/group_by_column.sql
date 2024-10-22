{% macro group_by_column(table_name,column_name) -%}
    select {{column_name}},count(*) Total from {{ ref(table_name) }} group by {{column_name}}
{%- endmacro %}