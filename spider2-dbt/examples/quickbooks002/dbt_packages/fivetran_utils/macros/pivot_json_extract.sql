{% macro pivot_json_extract(string, list_of_properties) %}

{%- for property in list_of_properties -%}
{%- if property is mapping -%}
replace( {{ fivetran_utils.json_extract(string, property.name) }}, '"', '') as {{ property.alias if property.alias else property.name | replace(' ', '_') | replace('.', '_') | lower }}

{%- else -%}
replace( {{ fivetran_utils.json_extract(string, property) }}, '"', '') as {{ property | replace(' ', '_') | lower }}

{%- endif -%}
{%- if not loop.last -%},{%- endif %}
{% endfor -%}

{% endmacro %}