-- Subtract one day back to revert end date back to its initial value in the end model
{% macro subtract_day_to_char_date(date_string) -%}

{{ adapter.dispatch('subtract_day_to_char_date') (date_string) }}

{%- endmacro %}

{% macro default__subtract_day_to_char_date(date_string) %}

    to_char(dateadd(day, -1, to_date({{ date_string }}, 'YYYYMMDD')), 'YYYYMMDD')

{% endmacro %}

{% macro postgres__subtract_day_to_char_date(date_string) %}

    to_char(to_date({{ date_string }}, 'YYYYMMDD') - interval '1 day', 'YYYYMMDD')

{% endmacro %}

{% macro bigquery__subtract_day_to_char_date(date_string) %}

    format_date('%Y%m%d', date_sub(parse_date('%Y%m%d', {{ date_string }}), interval 1 day))

{% endmacro %}

{% macro databricks__subtract_day_to_char_date(date_string) %}

    date_format(date_sub(to_date({{ date_string }}, 'yyyyMMdd'), 1), 'yyyyMMdd')

{% endmacro %}