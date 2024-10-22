{%- macro get_macro_columns(get_column_macro) -%}

    {%- set macro_column_names = [] -%}
    {%- for col in get_column_macro -%}
        {%- set macro_column_names = macro_column_names.append(col.name | upper if target.type == 'snowflake' else col.name) -%}
    {%- endfor -%}

{{ return(macro_column_names) }}
{%- endmacro -%}