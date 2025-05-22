{% macro snowflake_seed_data(seed_name) %}

{% if target.type == 'snowflake' %}
{{ return(ref(seed_name ~ '_snowflake')) }}
{% else %}
{{ return(ref(seed_name)) }}
{% endif %}

{% endmacro %}