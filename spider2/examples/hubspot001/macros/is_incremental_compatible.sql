{% macro is_incremental_compatible() -%}
    {{ return(adapter.dispatch('is_incremental_compatible', 'hubspot') ()) }}
{% endmacro %}

{% macro default__is_incremental_compatible() %}
    {{ return(False) }}
{% endmacro %}

{% macro bigquery__is_incremental_compatible() %}
    {{ return(True) }}
{% endmacro %}

{% macro snowflake__is_incremental_compatible() %}
    {{ return(True) }}
{% endmacro %}

{% macro postgres__is_incremental_compatible() %}
    {{ return(True) }}
{% endmacro %}

{% macro redshift__is_incremental_compatible() %}
    {{ return(True) }}
{% endmacro %}

{% macro databricks__is_incremental_compatible() %}
    {% set re = modules.re %}
    {% set path_match = target.http_path %}
    {% set regex_pattern = "sql/protocol" %}
    {% set match_result = re.search(regex_pattern, path_match) %}
    {% if match_result %}
        {{ return(True) }}
    {% else %}
        {{ return(False) }}
    {% endif %}
{% endmacro %}
