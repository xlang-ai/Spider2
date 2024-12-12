{%- macro recharge_does_table_exist(table_name) -%}

    {%- if execute -%}
    {%- set source_relation = adapter.get_relation(
        database=source('recharge', table_name).database,
        schema=source('recharge', table_name).schema,
        identifier=source('recharge', table_name).name) -%}

    {% set table_exists=source_relation is not none %}
    {{ return(table_exists) }}
    {%- endif -%} 

{% endmacro %}