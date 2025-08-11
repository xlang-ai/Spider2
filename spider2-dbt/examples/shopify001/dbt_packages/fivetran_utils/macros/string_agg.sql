
{% macro string_agg(field_to_agg, delimiter) -%}

{{ adapter.dispatch('string_agg', 'fivetran_utils') (field_to_agg, delimiter) }}

{%- endmacro %}

{% macro default__string_agg(field_to_agg, delimiter) %}
    string_agg({{ field_to_agg }}, {{ delimiter }})

{% endmacro %}

{% macro snowflake__string_agg(field_to_agg, delimiter) %}
    listagg({{ field_to_agg }}, {{ delimiter }})

{% endmacro %}

{% macro redshift__string_agg(field_to_agg, delimiter) %}
    listagg({{ field_to_agg }}, {{ delimiter }})

{% endmacro %}

{% macro spark__string_agg(field_to_agg, delimiter) %}
    -- collect set will remove duplicates
    replace(replace(replace(cast( collect_set({{ field_to_agg }}) as string), '[', ''), ']', ''), ', ', {{ delimiter }} )

{% endmacro %}