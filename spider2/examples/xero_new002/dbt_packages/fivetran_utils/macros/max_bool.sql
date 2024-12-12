{% macro max_bool(boolean_field) -%}

{{ adapter.dispatch('max_bool', 'fivetran_utils') (boolean_field) }}

{%- endmacro %}

--Default max_bool calculation
{% macro default__max_bool(boolean_field)  %}

    bool_or( {{ boolean_field }} )

{% endmacro %}

--max_bool calculation specific to Snowflake
{% macro snowflake__max_bool(boolean_field)  %}

    max( {{ boolean_field }} )

{% endmacro %}

--max_bool calculation specific to BigQuery
{% macro bigquery__max_bool(boolean_field)  %}

    max( {{ boolean_field }} )

{% endmacro %}