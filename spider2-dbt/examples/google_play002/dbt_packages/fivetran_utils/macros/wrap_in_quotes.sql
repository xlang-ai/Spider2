{%- macro wrap_in_quotes(object_to_quote) -%}

{{ return(adapter.dispatch('wrap_in_quotes', 'fivetran_utils')(object_to_quote)) }}

{%- endmacro -%}

{%- macro default__wrap_in_quotes(object_to_quote)  -%}
{# bigquery, spark, databricks #}
    `{{ object_to_quote }}`
{%- endmacro -%}

{%- macro snowflake__wrap_in_quotes(object_to_quote)  -%}
    "{{ object_to_quote | upper }}"
{%- endmacro -%}

{%- macro redshift__wrap_in_quotes(object_to_quote)  -%}
    "{{ object_to_quote }}"
{%- endmacro -%}

{%- macro postgres__wrap_in_quotes(object_to_quote)  -%}
    "{{ object_to_quote }}"
{%- endmacro -%}