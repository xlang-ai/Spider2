{% macro build_key_from_row_natural_id(input_col_list=[]) %}

{# {{% set row_natural_id = build_row_natural_id_from_columns(input_col_list) %}}} #}

{{ log("Running build_key_from_row_natural_id") }}

{{ return(dbt_utils.surrogate_key(build_row_natural_id_from_columns(input_col_list))) }}

{% endmacro %}