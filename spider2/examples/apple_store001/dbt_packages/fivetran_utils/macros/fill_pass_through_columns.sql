{% macro fill_pass_through_columns(pass_through_variable) %}

{% if var(pass_through_variable) %}
    {% for field in var(pass_through_variable) %}
        {% if field is mapping %}
            {% if field.transform_sql %}
                , {{ field.transform_sql }} as {{ field.alias if field.alias else field.name }}
            {% else %}
                , {{ field.alias if field.alias else field.name }}
            {% endif %}
        {% else %}
        , {{ field }}
        {% endif %}
    {% endfor %}
{% endif %}

{% endmacro %}