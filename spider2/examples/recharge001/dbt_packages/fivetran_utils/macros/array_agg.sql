{% macro array_agg(field_to_agg) -%}

{{ adapter.dispatch('array_agg', 'fivetran_utils') (field_to_agg) }}

{%- endmacro %}

{% macro default__array_agg(field_to_agg) %}
    array_agg({{ field_to_agg }})
{% endmacro %}

{% macro redshift__array_agg(field_to_agg) %}
    listagg({{ field_to_agg }}, ',')
{% endmacro %}