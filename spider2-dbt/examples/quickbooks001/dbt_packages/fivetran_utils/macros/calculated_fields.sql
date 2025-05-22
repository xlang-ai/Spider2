{% macro calculated_fields(variable) -%}

{% if var(variable, none) %}
    {% for field in var(variable) %}
        , {{ field.transform_sql }} as {{ field.name }} 
    {% endfor %}
{% endif %}

{% endmacro %}