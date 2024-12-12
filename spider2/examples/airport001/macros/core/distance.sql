{%- macro get_b_name_columns() -%}
    {%- set columns = dbt_utils.get_column_values(ref('stg_airports__malaysia_distances'), 'b_name') | list | sort -%}
    {%- for column in columns %}
        coalesce("{{ column }}", 0) as "{{ column }}"
        {%- if not loop.last -%}
        ,
        {%- endif -%}
    {%- endfor %}
{%- endmacro %}


{% macro get_b_name_value() %}
    {%- set columns = dbt_utils.get_column_values(ref('stg_airports__malaysia_distances'), 'b_name') | list | sort -%}
    {%- for column in columns %}
        ('{{ column }}')
        {%- if not loop.last -%}
        ,
        {%- endif -%}
    {%- endfor %}
{% endmacro %}


{% macro get_b_name_type(col_type='DOUBLE') %}
    {%- set columns = dbt_utils.get_column_values(ref('stg_airports__malaysia_distances'), 'b_name') | list | sort -%}
    {%- for column in columns %}
        "{{ column }}" {{ col_type }}
        {%- if not loop.last -%}
        ,
        {%- endif -%}
    {%- endfor %}
{% endmacro %}
