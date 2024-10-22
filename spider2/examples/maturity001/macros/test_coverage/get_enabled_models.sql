{% macro get_enabled_models() %}

    {% set enabled_models = [] %}

    {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "model") %}

        {% if node.config.enabled == True %}

            {% do enabled_models.append(node) %}

        {% endif %}

    {% endfor %}

    {% do return(enabled_models) %}
    
{% endmacro %}