--Convert date strings to dates, add one day, and then convert back to strings. This will avoid null records in our end model--the initial date range setup would join on date ranges in the end model that don't exist
{% macro add_day_to_char_date(date_string) -%}

{{ adapter.dispatch('add_day_to_char_date') (date_string) }}

{%- endmacro %}

{% macro default__add_day_to_char_date(date_string) %}

    to_char(dateadd(day, 1, to_date({{ date_string }}, 'YYYYMMDD')), 'YYYYMMDD')

{% endmacro %}

{% macro postgres__add_day_to_char_date(date_string) %}

    to_char(to_date({{ date_string }}, 'YYYYMMDD') + interval '1 day', 'YYYYMMDD')

{% endmacro %}

{% macro bigquery__add_day_to_char_date(date_string) %}

    format_date('%Y%m%d', date_add(parse_date('%Y%m%d', {{ date_string }}), interval 1 day))

{% endmacro %}

{% macro databricks__add_day_to_char_date(date_string) %}

    date_format(date_add(to_date({{ date_string }}, 'yyyyMMdd'), 1), 'yyyyMMdd')

{% endmacro %}


{% macro duckdb__add_day_to_char_date(date_string) %}

    strftime('%Y%m%d', date_add('1 day', strptime(cast({{ date_string }} as varchar), '%Y%m%d')))

{% endmacro %}
