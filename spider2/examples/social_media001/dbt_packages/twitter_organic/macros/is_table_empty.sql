{%- macro is_table_empty(table_name) -%}

{{ adapter.dispatch('is_table_empty', 'twitter_organic') (table_name) }}

{%- endmacro %}

{%- macro default__is_table_empty(table_name) -%}
    {%- if execute and flags.WHICH in ('run', 'build') %}
        {% set row_count_query %}
            select count(*) as row_count from {{ table_name }}
        {% endset %}
        {% set results = run_query(row_count_query) %}
        {% if results %}
            {% set row_count = results.columns[0][0] %}
            {% if row_count == 0 %}
                {{ return("empty") }}
            {% endif %}
        {% endif %}
    {% endif -%}
{%- endmacro -%}