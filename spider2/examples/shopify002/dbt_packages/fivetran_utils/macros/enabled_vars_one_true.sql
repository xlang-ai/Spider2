{% macro enabled_vars_one_true(vars) %}

{% for v in vars %}
    
    {% if var(v, False) == True %}
    {{ return(True) }}
    {% endif %}

{% endfor %}

{{ return(False) }}

{% endmacro %}