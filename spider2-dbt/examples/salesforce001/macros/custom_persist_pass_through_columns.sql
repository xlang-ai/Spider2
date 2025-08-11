{% macro custom_persist_pass_through_columns(pass_through_variable, identifier=none, transform='', append_string='') %}

{% if var(pass_through_variable, none) %}
    {% for field in var(pass_through_variable) %}
        , {{ transform ~ '(' ~ (identifier ~ '.' if identifier else '') ~ (field.alias if field.alias else field.name) ~ ')' }} as {{ field.alias if field.alias else field.name }}{{ append_string }}
    {% endfor %}
{% endif %}

{% endmacro %}