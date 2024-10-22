{% macro build_row_natural_id_from_columns(input_col_list=[]) %}

{% set output_col_list = [] %}

{{ log("Running build_row_natural_id_from_columns with output_col_list input_col_list: " ~ input_col_list) }}

{%- for col in input_col_list -%}

    {%- do output_col_list.append("coalesce(cast(" ~ col ~ " as " ~ dbt_utils.type_string() ~ "), '')")  -%}

{%- endfor -%}



{{ log("Running build_row_natural_id_from_columns with output_col_list: " ~ output_col_list) }}

{# {{% set output_str = output_col_list|join(', ') %}} #}

{{ return('concat(' ~ output_col_list|join(', \'|\' , ') ~ ')') }}

{% endmacro %}