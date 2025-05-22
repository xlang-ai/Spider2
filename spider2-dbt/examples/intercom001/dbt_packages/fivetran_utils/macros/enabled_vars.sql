{% macro enabled_vars(vars) %}

{% for v in vars %}
    
    {% if var(v, True) == False %}
    {{ return(False) }}
    {% endif %}

{% endfor %}

{{ return(True) }}

{% endmacro %}