{#
    This macro converts minutes and seconds to 0
#}
{% macro normalize_timestamp(column_value) -%}

strftime('%Y-%m-%d %H:00:00', date_trunc('hour', {{ column_value }}))

{%- endmacro %}
