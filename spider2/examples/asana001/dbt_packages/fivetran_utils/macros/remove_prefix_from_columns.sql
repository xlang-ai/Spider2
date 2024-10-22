{% macro remove_prefix_from_columns(columns, prefix='', exclude=[]) %}

        {%- for col in columns if col.name not in exclude -%}
        {%- if col.name[:prefix|length]|lower == prefix -%}
        {{ col.name }} as {{ col.name[prefix|length:] }}
        {%- else -%}
        {{ col.name }}
        {%- endif -%}
        {%- if not loop.last -%},{%- endif %}
        {% endfor -%}

{% endmacro %}