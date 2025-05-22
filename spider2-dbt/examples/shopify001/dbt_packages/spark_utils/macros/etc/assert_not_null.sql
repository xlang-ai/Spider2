{% macro assert_not_null(function, arg) -%}
  {{ return(adapter.dispatch('assert_not_null', 'spark_utils')(function, arg)) }}
{%- endmacro %}

{% macro default__assert_not_null(function, arg) %}

    coalesce({{function}}({{arg}}), nvl2({{function}}({{arg}}), assert_true({{function}}({{arg}}) is not null), null))

{% endmacro %}
