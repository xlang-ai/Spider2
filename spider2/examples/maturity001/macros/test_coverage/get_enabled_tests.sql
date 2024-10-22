{% macro get_enabled_tests() %}

    {% set enabled_tests = [] %}

    {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "test") %}

        {% if node.config.enabled == True %}

            {% do enabled_tests.append(node) %}

        {% endif %}

    {% endfor %}

    {% do return(enabled_tests) %}
    
{% endmacro %}