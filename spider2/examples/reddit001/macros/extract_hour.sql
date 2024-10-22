{#
    This macro extracts the hour of the timestamp
#}
{% macro extract_hour(column_name) -%}

strftime('%H', {{ column_name }})

{%- endmacro %}
