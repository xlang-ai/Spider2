{% macro spark__convert_timezone(in_tz, out_tz, in_timestamp) %}
    from_utc_timestamp(to_utc_timestamp({{in_timestamp}}, {{in_tz}}), {{out_tz}})
{% endmacro %}
