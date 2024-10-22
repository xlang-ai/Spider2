{% macro seed_data_helper(seed_name, warehouses) %}

{% if target.type in warehouses %}
    {% for w in warehouses %}
        {% if target.type == w %}
            {{ return(ref(seed_name ~ "_" ~ w ~ "")) }}
        {% endif %}
    {% endfor %}
{% else %}
{{ return(ref(seed_name)) }}
{% endif %}

{% endmacro %}