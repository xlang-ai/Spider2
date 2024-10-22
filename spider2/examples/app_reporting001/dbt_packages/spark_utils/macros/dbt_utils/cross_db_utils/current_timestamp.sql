{% macro spark__current_timestamp() %}
    current_timestamp()
{% endmacro %}


{% macro spark__current_timestamp_in_utc() %}
    unix_timestamp()
{% endmacro %}
