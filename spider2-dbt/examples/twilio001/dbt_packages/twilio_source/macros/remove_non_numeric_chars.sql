{% macro remove_non_numeric_chars(column) %}
    {{ return(adapter.dispatch('remove_non_numeric_chars') (column)) }}
{% endmacro %}



{% macro default__remove_non_numeric_chars(column) %}
    REGEXP_REPLACE(cast ({{ column }} as {{ dbt.type_string() }}), '[^0-9.-]', '')
{% endmacro %}


{% macro bigquery__remove_non_numeric_chars(column) %}

    REGEXP_REPLACE(cast ({{ column }} as {{ dbt.type_string() }}), r'[^0-9.-]', '')

{% endmacro %}

{% macro postgres__remove_non_numeric_chars(column) %}

    REGEXP_REPLACE(cast ({{ column }} as {{ dbt.type_string() }}), '[^0-9.-]', '', 'g')

{% endmacro %}

{% macro redshift__remove_non_numeric_chars(column) %}
    REGEXP_REPLACE(cast ({{ column }} as {{ dbt.type_string() }}), '[^0-9.-]', '')
{% endmacro %}

