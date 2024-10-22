{% macro rm_quotes(column_name) -%}

    {#-- Extra indentation so it appears inline when script is compiled. -#}
        replace({{ column_name }}, '"', '') as "{{ column_name }}"

{%- endmacro %}
