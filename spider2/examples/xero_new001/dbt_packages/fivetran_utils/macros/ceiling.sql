{% macro ceiling(num) -%}

{{ adapter.dispatch('ceiling', 'fivetran_utils') (num) }}

{%- endmacro %}

{% macro default__ceiling(num) %}
    ceiling({{ num }})

{% endmacro %}

{% macro snowflake__ceiling(num) %}
    ceil({{ num }})

{% endmacro %}
