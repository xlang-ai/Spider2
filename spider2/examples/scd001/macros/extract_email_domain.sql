{% macro extract_email_domain(email) %}
regexp_extract(lower({{ email }}), '@(.*)', 1)
{% endmacro %}
